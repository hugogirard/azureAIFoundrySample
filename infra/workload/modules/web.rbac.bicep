param acrResourceName string
param flightApiPrincipalId string

resource acr 'Microsoft.ContainerRegistry/registries@2025-04-01' existing = {
  name: acrResourceName
}

// Assign RBAC ACR Pull 7f951dda-4ed3-4680-a7ca-43fe172d538d
@description('Built-in Role: [ACR Pull]')
resource acrPullRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  scope: resourceGroup()
}

resource acrPullFlightApiAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acr
  name: guid(flightApiPrincipalId, acrPullRole.id, acr.id)
  properties: {
    principalId: flightApiPrincipalId
    roleDefinitionId: acrPullRole.id
    principalType: 'ServicePrincipal'
  }
}
