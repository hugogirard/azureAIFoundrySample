param suffix string
param location string
param infrastructureSubnetId string

resource environment 'Microsoft.App/managedEnvironments@2025-02-02-preview' = {
  name: 'aca-env-${suffix}'
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
    workloadProfiles: [
      {
        maximumCount: 1
        minimumCount: 1
        name: 'CAW01'
        workloadProfileType: 'D4'
      }
    ]
    vnetConfiguration: {
      infrastructureSubnetId: infrastructureSubnetId
      internal: false
    }
    zoneRedundant: false
  }
}
