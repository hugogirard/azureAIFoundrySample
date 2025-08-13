param userObjectId string
param cosmosDbResourceName string

resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
  name: cosmosDbResourceName
}

@description('Built-in Role: [Cosmos DB Built-in Data Contributor]')
resource cosmosDbDataContributorRole 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' existing = {
  name: '00000000-0000-0000-0000-000000000002'
  parent: cosmosdb
}

resource assignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  name: guid(cosmosDbDataContributorRole.id, userObjectId, cosmosdb.id)
  parent: cosmosdb
  properties: {
    principalId: userObjectId
    roleDefinitionId: cosmosDbDataContributorRole.id
    scope: cosmosdb.id
  }
}
