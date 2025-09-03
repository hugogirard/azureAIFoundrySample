param suffix string
param location string
param acrResourceName string

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
      ]
      linuxFxVersion: 'DOCKER|${acrResourceName}.azurecr.io/test:1'
      alwaysOn: true
      acrUseManagedIdentityCreds: true
    }
    serverFarmId: asp.id
  }
}

output fligtapiPrincipalId string = flightapi.identity.principalId
