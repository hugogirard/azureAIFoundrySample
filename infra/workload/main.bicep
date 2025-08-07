targetScope = 'subscription'

param privateEndpointSubnetResourceId string
param privateDnsRegistryResourceId string
param vnetResourceGroupName string
param subnetAcaResourceId string
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

/* Create container app environments 
   will host MCP Server, APIs and Web App
*/
module environment 'br/public:avm/res/app/managed-environment:0.11.2' = {
  scope: rgResources
  params: {
    name: 'aca-${suffix}'
    infrastructureSubnetResourceId: subnetAcaResourceId
    internal: true
    location: location
    publicNetworkAccess: 'Enabled'
    workloadProfiles: [
      {
        maximumCount: 1
        minimumCount: 1
        name: 'CAW01'
        workloadProfileType: 'D4'
      }
    ]
  }
}
