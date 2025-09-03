param suffix string
param location string
param acrResourceName string
param storageResourceName string
param cosmosResourceName string

resource asp 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: 'asp-${suffix}'
  location: location
  kind: 'linux'
  properties: {
    zoneRedundant: false
    reserved: true
  }
  sku: {
    tier: 'Premium0V3'
    name: 'P1V3'
  }
}

resource flightapi 'Microsoft.Web/sites@2024-11-01' = {
  name: 'flight-api-${suffix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrResourceName}.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
        {
          name: 'AZURE_STORAGE_ENDPOINT'
          value: 'https://${storageResourceName}.table.${environment().suffixes.storage}/'
        }
        {
          name: 'AZURE_STORAGE_AIRPORT_TABLE'
          value: 'airport'
        }
        {
          name: 'AZURE_STORAGE_FLIGHT_TABLE'
          value: 'flight'
        }
        {
          name: 'AZURE_COSMOSDB_ENDPOINT'
          value: 'https://${cosmosResourceName}.documents.azure.com:443/'
        }
        {
          name: 'COSMOS_DATABASE'
          value: 'flight'
        }
        {
          name: 'COSMOS_CONTAINER'
          value: 'bookings'
        }
        {
          name: 'IS_DEVELOPMENT'
          value: 'false'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrResourceName}.azurecr.io/test:1'
      alwaysOn: true
      acrUseManagedIdentityCreds: true
    }
    serverFarmId: asp.id
  }
}

output fligtapiPrincipalId string = flightapi.identity.principalId
output flightApiWebAppName string = flightapi.name
