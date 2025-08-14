param suffix string
param location string

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
    siteConfig: {}
  }
}

output fligtapiPrincipalId string = flightapi.identity.principalId
