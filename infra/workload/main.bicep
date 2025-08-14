targetScope = 'subscription'

param privateEndpointSubnetResourceId string
param privateDnsRegistryResourceId string
param privateDnsStorableTableResourceId string
param privateDnsCosmosDBResourceId string
param userObjectId string
param subnetAcaResourceId string
param workloadResourceGroupName string
param location string
param lockdown bool

var publicNetworkAccess = lockdown ? 'Disabled' : 'Enabled'

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
    publicNetworkAccess: publicNetworkAccess
    exportPolicyStatus: 'enabled'
    acrAdminUserEnabled: true
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

var networkAcls = lockdown
  ? {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  : {
      defaultAction: 'Allow'
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
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAcls
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
    ]
  }
}

var privateEndpointCosmosDB = lockdown
  ? [
      {
        service: 'sql'
        subnetResourceId: privateEndpointSubnetResourceId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsCosmosDBResourceId
            }
          ]
        }
      }
    ]
  : null

module databaseAccount 'br/public:avm/res/document-db/database-account:0.15.0' = {
  scope: rgResources
  params: {
    name: 'cosmos-${suffix}'
    location: location
    disableLocalAuthentication: true
    automaticFailover: false
    networkRestrictions: {
      networkAclBypass: 'AzureServices'
      publicNetworkAccess: publicNetworkAccess
    }
    sqlDatabases: [
      {
        name: 'flight'
        throughput: 600
        autoscaleSettingsMaxThroughput: 4000
        containers: [
          {
            indexingPolicy: {
              automatic: true
            }
            name: 'bookings'
            paths: [
              '/username'
            ]
          }
        ]
      }
    ]
    failoverLocations: [
      {
        failoverPriority: 0
        isZoneRedundant: false
        locationName: location
      }
    ]
    zoneRedundant: false
    privateEndpoints: privateEndpointCosmosDB
  }
}

module rbac_user 'modules/user.rbac.bicep' = if (userObjectId != '' && userObjectId != null) {
  scope: rgResources
  params: {
    cosmosDbResourceName: databaseAccount.outputs.name
    userObjectId: userObjectId
  }
}

output acaEnvironmentResourceName string = environment.outputs.acaEnvironmentResourceName
output acaResourceId string = environment.outputs.acaResourceId
output storageResourceId string = storageAccount.outputs.resourceId
output storageAccountName string = storageAccount.outputs.name
output storageTableEndpoint string = 'https://${storageAccount.outputs.name}.table.core.windows.net/'
output cosmosDbEndpoint string = 'https://${databaseAccount.outputs.name}.documents.azure.com:443/'
output airportTableName string = storageTables.outputs.tableNames[0]
output flightTableName string = storageTables.outputs.tableNames[1]
output cosmosDbName string = databaseAccount.outputs.name
output acrServerEndpoint string = registry.outputs.loginServer
