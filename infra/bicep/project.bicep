param projectName string
param projectDescription string
param projectDisplayName string
param location string
param existingAiSearchResourceName string
param existingAzureCosmosDBAccountResourceName string
param existingAzureStorageAccountResourceName string
param existingAiAccountName string

module aiProject 'modules/ai-project-identity.bicep' = {
  params: {
    // workspace organization
    projectName: projectName
    projectDescription: projectDescription
    displayName: projectDisplayName
    location: location
    aiSearchName: existingAiSearchResourceName
    cosmosDBName: existingAzureCosmosDBAccountResourceName
    azureStorageName: existingAzureStorageAccountResourceName
    accountName: existingAiAccountName
  }
}

module formatProjectWorkspaceId 'modules/format-project-workspace-id.bicep' = {
  params: {
    projectWorkspaceId: aiProject.outputs.projectWorkspaceId
  }
}

/*
  Assigns the project SMI the storage blob data contributor role on the storage account
*/
module storageAccountRoleAssignment 'modules/azure-storage-account-role-assignment.bicep' = {
  params: {
    azureStorageName: existingAzureStorageAccountResourceName
    projectPrincipalId: aiProject.outputs.projectPrincipalId
  }
}

// The Comos DB Operator role must be assigned before the caphost is created
module cosmosAccountRoleAssignments 'modules/cosmosdb-account-role-assignment.bicep' = {
  params: {
    cosmosDBName: existingAzureCosmosDBAccountResourceName
    projectPrincipalId: aiProject.outputs.projectPrincipalId
  }
}

// This role can be assigned before or after the caphost is created
module aiSearchRoleAssignments 'modules/ai-search-role-assignments.bicep' = {
  params: {
    aiSearchName: existingAiSearchResourceName
    projectPrincipalId: aiProject.outputs.projectPrincipalId
  }
}

// The name of the project capability host to be created
var projectCapHost string = 'cap-${projectName}'
param deploymentTimestamp string = utcNow('yyyyMMddHHmmss')
var uniqueSuffix = substring(uniqueString('${resourceGroup().id}-${deploymentTimestamp}'), 0, 4)

// This module creates the capability host for the project and account
module addProjectCapabilityHost 'modules/add-project-capability-host.bicep' = {
  name: 'capabilityHost-configuration-${uniqueSuffix}-deployment'
  params: {
    accountName: existingAiAccountName
    projectName: aiProject.outputs.projectName
    cosmosDBConnection: aiProject.outputs.cosmosDBConnection
    azureStorageConnection: aiProject.outputs.azureStorageConnection
    aiSearchConnection: aiProject.outputs.aiSearchConnection
    projectCapHost: projectCapHost
  }
  dependsOn: [
    cosmosAccountRoleAssignments
    storageAccountRoleAssignment
    aiSearchRoleAssignments
  ]
}

// The Storage Blob Data Owner role must be assigned after the caphost is created
module storageContainersRoleAssignment 'modules/blob-storage-container-role-assignments.bicep' = {
  params: {
    aiProjectPrincipalId: aiProject.outputs.projectPrincipalId
    storageName: existingAzureStorageAccountResourceName
    workspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
  }
  dependsOn: [
    addProjectCapabilityHost
  ]
}

// The Cosmos Built-In Data Contributor role must be assigned after the caphost is created
module cosmosContainerRoleAssignments 'modules/cosmos-container-role-assignments.bicep' = {
  params: {
    cosmosAccountName: existingAzureCosmosDBAccountResourceName
    projectWorkspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
    projectPrincipalId: aiProject.outputs.projectPrincipalId
  }
  dependsOn: [
    addProjectCapabilityHost
    storageContainersRoleAssignment
  ]
}
