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
    name: 'P0V3'
  }
}
