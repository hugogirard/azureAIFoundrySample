targetScope = 'subscription'

param privateEndpointSubnetResourceId string
param privateDnsRegistryResourceId string
param privateDnsStorableTableResourceId string
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
module environment 'modules/environment.bicep' = {
  scope: rgResources
  params: {
    location: location
    infrastructureSubnetId: subnetAcaResourceId
    suffix: suffix
  }
}

/* Storage needed for tables, queues and blob */
module storageAccount 'br/public:avm/res/storage/storage-account:0.25.0' = {
  scope: rgResources
  params: {
    name: 'str${replace(suffix,'-','')}'
    location: location
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    privateEndpoints: [
      {
        service: 'table'
        subnetResourceId: privateEndpointSubnetResourceId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsStorableTableResourceId
            }
          ]
        }
      }
    ]
    allowSharedKeyAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

/* Create tables for the flight API */
module storageTables 'modules/storage-tables.bicep' = {
  scope: rgResources
  dependsOn: [storageAccount]
  params: {
    storageAccountName: 'str${replace(suffix,'-','')}'
    tableNames: [
      'airporttable'
      'flighttable'
      'booking'
    ]
  }
}

output acaEnvironmentResourceName string = environment.outputs.acaEnvironmentResourceName
output acaResourceId string = environment.outputs.acaResourceId
output storageResourceId string = storageAccount.outputs.resourceId
output airportTableName string = storageTables.outputs.tableNames[0]
output flightTableName string = storageTables.outputs.tableNames[1]
output bookingTableName string = storageTables.outputs.tableNames[2]
