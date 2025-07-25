param subnetAddressPrefix string
param location string
param publisherEmail string
param publisherName string
param suffix string

resource existingVnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: 'vnet-ai'
}

resource apimNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'nsg-apim'
  location: location
  properties: {
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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  parent: existingVnet
  name: 'snet-apim'
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: {
      id: apimNSG.id
    }
  }
}

module pip 'br/public:avm/res/network/public-ip-address:0.9.0' = {
  params: {
    name: 'pip-apim'
  }
}

module apim 'br/public:avm/res/api-management/service:0.9.1' = {
  params: {
    // Required parameters
    name: 'api-${suffix}'
    publisherEmail: publisherEmail
    publisherName: publisherName
    // Non-required parameters
    enableDeveloperPortal: true
    sku: 'Developer'
    virtualNetworkType: 'External'
    subnetResourceId: subnet.id
    publicIpAddressResourceId: pip.outputs.resourceId
  }
}
