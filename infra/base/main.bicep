targetScope = 'subscription'

param resourceGroupNameVNET string

param resourceGroupName string

param vnetAddressPrefix string

param subnetAgentAddressPrefix string

param subnetPrivateEndpointAddressPrefix string

param subnetJumpboxAddressPrefix string

param apimSubnetAddressPrefix string

param subnetWebFarmAddressPrefix string

param publisherEmail string

param publisherName string

@secure()
param adminUserName string

@secure()
param adminPassword string

param location string

var dnsZones = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.documents.azure.com'
  'privatelink.openai.azure.com'
  'privatelink.services.ai.azure.com'
  'privatelink.search.windows.net'
  'privatelink.azurecr.io'
  'privatelink.table.${environment().suffixes.storage}'
]

resource rgVNET 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupNameVNET
  location: location
}

resource rgResources 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

module nsg 'br/public:avm/res/network/network-security-group:0.5.1' = {
  scope: rgVNET
  params: {
    name: 'nsg-jumpbox'
  }
}

module apiNsg 'br/public:avm/res/network/network-security-group:0.5.1' = {
  scope: rgVNET
  params: {
    name: 'nsg-apim'
    location: location
    securityRules: [
      {
        name: 'AllowApimManagement'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'ApiManagement'
          protocol: 'Tcp'
          destinationPortRange: '3443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureLoadBalancer'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'AzureLoadBalancer'
          protocol: 'Tcp'
          destinationPortRange: '6390'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureTrafficManager'
        properties: {
          priority: 2020
          sourceAddressPrefix: 'AzureTrafficManager'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowStorage'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'AllowSql'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '1433'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'SQL'
        }
      }
      {
        name: 'AllowKeyVault'
        properties: {
          priority: 2020
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
        }
      }
      {
        name: 'AllowMonitor'
        properties: {
          priority: 2030
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRanges: ['1886', '443']
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureMonitor'
        }
      }
    ]
  }
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.0' = {
  scope: rgVNET
  params: {
    // Required parameters
    addressPrefixes: [
      vnetAddressPrefix
    ]
    name: 'vnet-ai'
    // Non-required parameters
    location: location
    subnets: [
      {
        name: 'snet-agent'
        addressPrefix: subnetAgentAddressPrefix
        delegation: 'Microsoft.App/environments'
      }
      {
        name: 'snet-pe'
        addressPrefix: subnetPrivateEndpointAddressPrefix
      }
      {
        name: 'snet-jumpbox'
        addressPrefix: subnetJumpboxAddressPrefix
        networkSecurityGroupResourceId: nsg.outputs.resourceId
      }
      {
        name: 'snet-apim'
        addressPrefix: apimSubnetAddressPrefix
        networkSecurityGroupResourceId: apiNsg.outputs.resourceId
      }
      {
        name: 'snet-api'
        addressPrefix: subnetWebFarmAddressPrefix
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
  }
}

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = [
  for name in dnsZones: {
    scope: rgVNET
    name: 'create-dns-${name}'
    params: {
      // Required parameters
      name: name
      virtualNetworkLinks: [
        {
          registrationEnabled: false
          virtualNetworkResourceId: virtualNetwork.outputs.resourceId
        }
      ]
    }
  }
]

var suffix = uniqueString(rgResources.id)

/* APIM */
module pip 'br/public:avm/res/network/public-ip-address:0.9.0' = {
  scope: rgVNET
  params: {
    name: 'pip-apim'
  }
}

module apim 'br/public:avm/res/api-management/service:0.9.1' = {
  scope: rgResources
  params: {
    // Required parameters
    name: 'apim-${suffix}'
    publisherEmail: publisherEmail
    publisherName: publisherName
    // Non-required parameters
    enableDeveloperPortal: true
    sku: 'Developer'
    virtualNetworkType: 'External' // Here for simplicity we use External mode but it should be
    // with a WAF in front and internal mode
    subnetResourceId: virtualNetwork.outputs.subnetResourceIds[3]
  }
}

module searchService 'br/public:avm/res/search/search-service:0.10.0' = {
  scope: rgResources
  params: {
    name: 'search-${suffix}'
    location: location
    replicaCount: 1
    partitionCount: 1
    sku: 'standard'
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZone[5].outputs.resourceId
            }
          ]
        }
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[1]
      }
    ]
    // Here since it's an agent dependencies no needs to expose it 
    // publicaly, for debugging we use the jumpbox
    publicNetworkAccess: 'Disabled'
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.25.0' = {
  scope: rgResources
  params: {
    name: 'str${replace(suffix,'-','')}'
    location: location
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    privateEndpoints: [
      {
        service: 'blob'
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[1]
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZone[0].outputs.resourceId
            }
          ]
        }
      }
    ]
    allowSharedKeyAccess: false
    // Here since it's an agent dependencies no needs to expose it 
    // publicaly, for debugging we use the jumpbox    
    publicNetworkAccess: 'Disabled'
  }
}

module databaseAccount 'br/public:avm/res/document-db/database-account:0.15.0' = {
  scope: rgResources
  params: {
    name: 'cosmos-${suffix}'
    location: location
    disableLocalAuthentication: true
    automaticFailover: false
    networkRestrictions: {
      networkAclBypass: 'AzureServices'
      // Here since it's an agent dependencies no needs to expose it 
      // publicaly, for debugging we use the jumpbox      
      publicNetworkAccess: 'Disabled'
    }
    failoverLocations: [
      {
        failoverPriority: 0
        isZoneRedundant: false
        locationName: location
      }
    ]
    zoneRedundant: false
    privateEndpoints: [
      {
        service: 'sql'
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[1]
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZone[2].outputs.resourceId
            }
          ]
        }
      }
    ]
  }
}

module buildAgent 'br/public:avm/res/compute/virtual-machine:0.15.1' = {
  scope: rgVNET
  params: {
    name: 'buildAgent'
    adminUsername: adminUserName
    adminPassword: adminPassword
    disablePasswordAuthentication: false
    imageReference: {
      offer: '0001-com-ubuntu-server-jammy'
      publisher: 'canonical'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            pipConfiguration: {
              publicIpNameSuffix: '-pip-01'
              zones: []
            }
            subnetResourceId: virtualNetwork.outputs.subnetResourceIds[2]
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    encryptionAtHost: false
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Linux'
    vmSize: 'Standard_D2ls_v5'
    zone: 0
    autoShutdownConfig: {
      dailyRecurrenceTime: '23:59'
      status: 'Enabled'
      timeZone: 'UTC'
    }
  }
}

module jumpbox 'br/public:avm/res/compute/virtual-machine:0.15.1' = {
  scope: rgVNET
  params: {
    adminUsername: adminUserName
    imageReference: {
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    name: 'jumpbox'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            pipConfiguration: {
              publicIpNameSuffix: '-pip-01'
              zones: []
            }
            subnetResourceId: virtualNetwork.outputs.subnetResourceIds[2]
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    encryptionAtHost: false
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_D2s_v3'
    zone: 0
    adminPassword: adminPassword
    location: location
    autoShutdownConfig: {
      dailyRecurrenceTime: '23:59'
      status: 'Enabled'
      timeZone: 'UTC'
    }
  }
}

//Add the A Record of the Jumpbox
module jumpboxARecord 'create_dns_record.bicep' = [
  for name in dnsZones: {
    scope: rgVNET
    dependsOn: [
      privateDnsZone
    ]
    params: {
      recordName: jumpbox.outputs.name
      #disable-next-line all
      ipv4Address: jumpbox.outputs.nicConfigurations[0].ipConfigurations[0].privateIP
      privateDnsZoneName: name
    }
  }
]

// Add the A Record for the build agent
module buildARecord 'create_dns_record.bicep' = [
  for name in dnsZones: {
    scope: rgVNET
    dependsOn: [
      privateDnsZone
    ]
    params: {
      recordName: buildAgent.outputs.name
      #disable-next-line all
      ipv4Address: buildAgent.outputs.nicConfigurations[0].ipConfigurations[0].privateIP
      privateDnsZoneName: name
    }
  }
]

output resourceGroupName string = rgResources.name
output location string = location
output vnetResourceName string = virtualNetwork.outputs.name
output vnetResourceGroupName string = rgVNET.name
output subnetAgentResourceId string = virtualNetwork.outputs.subnetResourceIds[0]
output subnetPrivateEndpointResourceId string = virtualNetwork.outputs.subnetResourceIds[1]
output subnetPrivateEndpointResourceName string = virtualNetwork.outputs.subnetNames[1]
output aiServicesPrivateDnsZoneResourceName string = privateDnsZone[4].outputs.name
output cognitiveServicesPrivateDnsZoneResourceName string = privateDnsZone[1].outputs.name
output openAiPrivateDnsZoneResourceName string = privateDnsZone[3].outputs.name
output privateDnsResourceGroupName string = rgVNET.name
output aiSearchResourceName string = searchService.outputs.name
output azureCosmosDBAccountResourceName string = databaseAccount.outputs.name
output storageAccountResourceName string = storageAccount.outputs.name
output privateDnsRegistryResourceId string = privateDnsZone[6].outputs.resourceId
output subnetAcaResourceId string = virtualNetwork.outputs.subnetResourceIds[4]
output cosmosDBPrivateDnsZoneResourceId string = privateDnsZone[2].outputs.resourceId
output tableStoragePrivateDnsZoneResourceId string = privateDnsZone[7].outputs.resourceId
output apimResourceName string = apim.outputs.name
