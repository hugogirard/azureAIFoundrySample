@description('Location for all resources.')
param location string

@description('Name for your AI Services resource.')
param aiServices string

@description('Deploy a project with the AI Foundry')
param deployProject bool

@description('Deploy AI Foundry in private mode')
param privateFoundry bool

@description('Name for your project resource.')
param projectName string

@description('This project will be a sub-resource of your account')
param projectDescription string

@description('The display name of the project')
param projectDisplayName string

@description('Name of the existing virtual network')
param existingVnetName string

@description('The resource group of the virtual network')
param existingVnetResourceGroupName string

@description('The name of the existing agents Subnet')
param existingAgentSubnetName string

@description('The name of the existing private Endpoint subnet')
param existingPeSubnetName string

@description('Existing AI Search Resource Name')
param existingAiSearchResourceName string

@description('Existing Storage Resource Name')
param existingAzureStorageAccountResourceName string

@description('Existing CosmosDB Resource Name')
param existingAzureCosmosDBAccountResourceName string

@description('The Private DNS Zone for services.ai.azure.com')
param aiServicesPrivateDnsZoneResourceName string

@description('The Private DNS Zone for openai.azure.com')
param openAiPrivateDnsZoneResourceName string

@description('The Private DNS Zone for cognitiveservices.azure.com')
param cognitiveServicesPrivateDnsZoneResourceName string

@description('The subscription ID of the private DNS Zones')
param privateDnsSubscriptionId string

@description('The resource group name of the private DNS Zones')
param privateDnsResourceGroupName string

var accountName = toLower('${aiServices}')

/*
  Get the existing vnet reference
*/
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: existingVnetName
  scope: resourceGroup(existingVnetResourceGroupName)
}

resource agentSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  parent: vnet
  name: existingAgentSubnetName
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  parent: vnet
  name: existingPeSubnetName
}

/*
  Create the AI Services account and gpt-4o model deployment
*/
module aiAccount 'modules/ai-account-identity.bicep' = {
  params: {
    accountName: accountName
    location: location
    agentSubnetId: agentSubnet.id
    privateEndpointSubnetId: peSubnet.id
    privateFoundry: privateFoundry
  }
}

module dnsLink 'modules/private-dns.bicep' = if (privateFoundry) {
  scope: resourceGroup(privateDnsSubscriptionId, privateDnsResourceGroupName)
  params: {
    aiAccountResourceName: aiAccount.outputs.accountName
    aiServicesPrivateDnsZoneResourceName: aiServicesPrivateDnsZoneResourceName
    cognitiveServicesPrivateDnsZoneResourceName: cognitiveServicesPrivateDnsZoneResourceName
    openAiPrivateDnsZoneResourceName: openAiPrivateDnsZoneResourceName
    privateEndpointIPAIFoundryService: aiAccount.outputs.privateEndpointPrivateIP
  }
}

module project 'project.bicep' = if (deployProject) {
  params: {
    location: location
    existingAiAccountName: aiAccount.outputs.accountName
    existingAiSearchResourceName: existingAiSearchResourceName
    existingAzureCosmosDBAccountResourceName: existingAzureCosmosDBAccountResourceName
    existingAzureStorageAccountResourceName: existingAzureStorageAccountResourceName
    projectDescription: projectDescription
    projectDisplayName: projectDisplayName
    projectName: projectName
  }
}

// module aiProject 'modules/ai-project-identity.bicep' = {
//   params: {
//     // workspace organization
//     projectName: projectName
//     projectDescription: projectDescription
//     displayName: projectDisplayName
//     location: location
//     aiSearchName: existingAiSearchResourceName
//     cosmosDBName: existingAzureCosmosDBAccountResourceName
//     azureStorageName: existingAzureStorageAccountResourceName
//     accountName: aiAccount.outputs.accountName
//   }
//   dependsOn: [
//     dnsLink
//   ]
// }

// module formatProjectWorkspaceId 'modules/format-project-workspace-id.bicep' = {
//   params: {
//     projectWorkspaceId: aiProject.outputs.projectWorkspaceId
//   }
// }

// /*
//   Assigns the project SMI the storage blob data contributor role on the storage account
// */
// module storageAccountRoleAssignment 'modules/azure-storage-account-role-assignment.bicep' = {
//   params: {
//     azureStorageName: existingAzureStorageAccountResourceName
//     projectPrincipalId: aiProject.outputs.projectPrincipalId
//   }
//   dependsOn: [
//     dnsLink
//   ]
// }

// // The Comos DB Operator role must be assigned before the caphost is created
// module cosmosAccountRoleAssignments 'modules/cosmosdb-account-role-assignment.bicep' = {
//   params: {
//     cosmosDBName: existingAzureCosmosDBAccountResourceName
//     projectPrincipalId: aiProject.outputs.projectPrincipalId
//   }
//   dependsOn: [
//     dnsLink
//   ]
// }

// // This role can be assigned before or after the caphost is created
// module aiSearchRoleAssignments 'modules/ai-search-role-assignments.bicep' = {
//   params: {
//     aiSearchName: existingAiSearchResourceName
//     projectPrincipalId: aiProject.outputs.projectPrincipalId
//   }
//   dependsOn: [
//     dnsLink
//   ]
// }

// // The name of the project capability host to be created
// var projectCapHost string = 'cap-${projectName}'
// param deploymentTimestamp string = utcNow('yyyyMMddHHmmss')
// var uniqueSuffix = substring(uniqueString('${resourceGroup().id}-${deploymentTimestamp}'), 0, 4)

// // This module creates the capability host for the project and account
// module addProjectCapabilityHost 'modules/add-project-capability-host.bicep' = {
//   name: 'capabilityHost-configuration-${uniqueSuffix}-deployment'
//   params: {
//     accountName: aiAccount.outputs.accountName
//     projectName: aiProject.outputs.projectName
//     cosmosDBConnection: aiProject.outputs.cosmosDBConnection
//     azureStorageConnection: aiProject.outputs.azureStorageConnection
//     aiSearchConnection: aiProject.outputs.aiSearchConnection
//     projectCapHost: projectCapHost
//   }
//   dependsOn: [
//     dnsLink
//     cosmosAccountRoleAssignments
//     storageAccountRoleAssignment
//     aiSearchRoleAssignments
//   ]
// }

// // The Storage Blob Data Owner role must be assigned after the caphost is created
// module storageContainersRoleAssignment 'modules/blob-storage-container-role-assignments.bicep' = {
//   params: {
//     aiProjectPrincipalId: aiProject.outputs.projectPrincipalId
//     storageName: existingAzureStorageAccountResourceName
//     workspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
//   }
//   dependsOn: [
//     addProjectCapabilityHost
//   ]
// }

// // The Cosmos Built-In Data Contributor role must be assigned after the caphost is created
// module cosmosContainerRoleAssignments 'modules/cosmos-container-role-assignments.bicep' = {
//   params: {
//     cosmosAccountName: existingAzureCosmosDBAccountResourceName
//     projectWorkspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
//     projectPrincipalId: aiProject.outputs.projectPrincipalId
//   }
//   dependsOn: [
//     addProjectCapabilityHost
//     storageContainersRoleAssignment
//   ]
// }
