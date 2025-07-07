targetScope = 'subscription'

param resourceGroupName string
param vnetAddressPrefix string

param subnetAgentAddressPrefix string

param subnetPrivateEndpointAddressPrefix string

param subnetJumpboxAddressPrefix string

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
]

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

module nsg 'br/public:avm/res/network/network-security-group:0.5.1' = {
  scope: rg
  params: {
    name: 'nsg-jumpbox'
  }
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.0' = {
  scope: rg
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
    ]
  }
}

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = [
  for name in dnsZones: {
    scope: rg
    params: {
      // Required parameters
      name: name
      virtualNetworkLinks: [
        {
          registrationEnabled: false
          virtualNetworkResourceId: virtualNetwork.outputs.resourceId
        }
      ]
      // a: [
      //   {
      //     aRecords: [
      //       {
      //         ipv4Address: jumpbox.outputs.nicConfigurations[0].ipConfigurations[0].privateIP
      //       }
      //     ]
      //     name: jumpbox.outputs.name
      //     ttl: 10
      //   }
      // ]
    }
  }
]

var suffix = uniqueString(rg.id)

module searchService 'br/public:avm/res/search/search-service:0.10.0' = {
  scope: rg
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
    publicNetworkAccess: 'Disabled'
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.25.0' = {
  scope: rg
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
    publicNetworkAccess: 'Disabled'
  }
}

module databaseAccount 'br/public:avm/res/document-db/database-account:0.15.0' = {
  scope: rg
  params: {
    name: 'cosmos-${suffix}'
    location: location
    disableLocalAuthentication: true
    automaticFailover: false
    networkRestrictions: {
      networkAclBypass: 'AzureServices'
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

module jumpbox 'br/public:avm/res/compute/virtual-machine:0.15.1' = {
  scope: rg
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

// Add the A Record of the Jumpbox
module jumpboxARecord 'create_dns_record.bicep' = [
  for name in dnsZones: {
    scope: rg
    params: {
      recordName: jumpbox.outputs.name
      ipv4Address: jumpbox.outputs.nicConfigurations[0].ipConfigurations[0].privateIP
      privateDnsZoneName: name
    }
  }
]

output resourceGroupName string = rg.name
output location string = location
output vnetResourceName string = virtualNetwork.outputs.name
output subnetAgentResourceName string = virtualNetwork.outputs.subnetNames[0]
output subnetPrivateEndpointResourceName string = virtualNetwork.outputs.subnetNames[1]
output aiServicesPrivateDnsZoneResourceName string = privateDnsZone[4].outputs.name
output cognitiveServicesPrivateDnsZoneResourceName string = privateDnsZone[1].outputs.name
output openAiPrivateDnsZoneResourceName string = privateDnsZone[3].outputs.name
output privateDnsResourceGroupName string = rg.name
output aiSearchResourceName string = searchService.outputs.name
output azureCosmosDBAccountResourceName string = databaseAccount.outputs.name
output storageAccountResourceName string = storageAccount.outputs.name
