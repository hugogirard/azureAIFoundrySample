param principalId string
param storageResourceName string

resource storage 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
  name: storageResourceName
}

@description('Built-in Role: [Storage Table Data Contributor]')
resource storageTableDataContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  scope: storage
}

resource acrPullFlightApiAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(storageTableDataContributorRole.id, principalId, storage.id)
  properties: {
    principalId: principalId
    roleDefinitionId: storageTableDataContributorRole.id
    principalType: 'ServicePrincipal'
  }
}
