targetScope = 'subscription'

param privateEndpointSubnetResourceId string
param privateDnsRegistryResourceId string
//param vnetResourceGroupName string
param workloadResourceGroupName string
param location string

resource rgResources 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: workloadResourceGroupName
  location: location
}

var suffix = replace(uniqueString(rgResources.id), '-', '')

module registry 'br/public:avm/res/container-registry/registry:0.9.1' = {
  scope: rgResources
  params: {
    name: 'acr${suffix}'
    location: location
    acrSku: 'Premium'
    publicNetworkAccess: 'Disabled'
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsRegistryResourceId
            }
          ]
        }
        subnetResourceId: privateEndpointSubnetResourceId
      }
    ]
  }
}
