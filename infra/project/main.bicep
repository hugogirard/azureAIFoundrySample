param foundryResourceName string
param storageResourceName string
param aiSearchResourceName string
param cosmosDbResourceName string
param location string
param projectName string
param projectDescription string
param projectDisplayName string

/* Reference existing Azure dependencies */
resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageResourceName
}

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: aiSearchResourceName
}

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
  name: cosmosDbResourceName
}

/* Reference Azure AI Foundry */
resource foundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: foundryResourceName
  scope: resourceGroup()
}

/* Create a new project */
resource project 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  parent: foundry
  name: projectName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: projectDescription
    displayName: projectDisplayName
  }

  resource project_connection_cosmosdb_account 'connections@2025-04-01-preview' = {
    name: cosmosDbResourceName
    properties: {
      category: 'CosmosDB'
      target: cosmosDB.properties.documentEndpoint
      authType: 'AAD'
      metadata: {
        ApiType: 'Azure'
        ResourceId: cosmosDB.id
        location: cosmosDB.location
      }
    }
  }

  resource project_connection_azure_storage 'connections@2025-04-01-preview' = {
    name: storageResourceName
    properties: {
      category: 'AzureStorageAccount'
      target: storage.properties.primaryEndpoints.blob
      authType: 'AAD'
      metadata: {
        ApiType: 'Azure'
        ResourceId: storage.id
        location: storage.location
      }
    }
  }

  resource project_connection_azureai_search 'connections@2025-04-01-preview' = {
    name: aiSearchResourceName
    properties: {
      category: 'CognitiveSearch'
      target: 'https://${aiSearchResourceName}.search.windows.net'
      authType: 'AAD'
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiSearch.id
        location: aiSearch.location
      }
    }
  }
}

#disable-next-line BCP053
var projectWorkspaceId = project.properties.internalId
var cosmosDBConnection = cosmosDbResourceName
var azureStorageConnection = storageResourceName
var aiSearchConnection = aiSearchResourceName

// Formating project workspace ID
var part1 = substring(projectWorkspaceId, 0, 8) // First 8 characters
var part2 = substring(projectWorkspaceId, 8, 4) // Next 4 characters
var part3 = substring(projectWorkspaceId, 12, 4) // Next 4 characters
var part4 = substring(projectWorkspaceId, 16, 4) // Next 4 characters
var part5 = substring(projectWorkspaceId, 20, 12) // Remaining 12 characters

var projectWorkspaceIdGuid = '${part1}-${part2}-${part3}-${part4}-${part5}'

// Add RBAC roles needed for the connection of the projects
module rbacProject 'rbac.project.bicep' = {
  params: {
    aiSearchName: aiSearchResourceName
    azureStorageName: storageResourceName
    cosmosDBName: cosmosDbResourceName
    projectPrincipalId: project.identity.principalId
  }
}

// This module creates the capability host for the project and account
// needed to use your own resources connections
module capabilityhost 'add-project-capability-host.bicep' = {
  dependsOn: [
    rbacProject // Permission needs to be assigned first
  ]
  params: {
    accountName: foundryResourceName
    aiSearchConnection: aiSearchConnection
    azureStorageConnection: azureStorageConnection
    cosmosDBConnection: cosmosDBConnection
    projectCapHost: toLower(projectName)
    projectName: projectName
  }
}

// Rbac after the capability host
module postRbacProject 'post.rbac.bicep' = {
  dependsOn: [
    capabilityhost
    rbacProject
  ]
  params: {
    aiProjectPrincipalId: project.identity.principalId
    cosmosAccountName: cosmosDbResourceName
    projectPrincipalId: project.identity.principalId
    projectWorkspaceId: projectWorkspaceIdGuid
    storageName: storageResourceName
    workspaceId: projectWorkspaceIdGuid
  }
}
