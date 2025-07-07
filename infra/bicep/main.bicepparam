using 'main.bicep'

param aiServices = ''

param existingVnetName = ''

param existingVnetResourceGroupName = ''

param location = ''

param existingAgentSubnetName = ''

param existingPeSubnetName = ''

param aiServicesPrivateDnsZoneResourceName = ''

param cognitiveServicesPrivateDnsZoneResourceName = ''

param openAiPrivateDnsZoneResourceName = 'privatelink.openai.azure.com'

param privateDnsResourceGroupName = 'rg-private-dns-zone'

param privateDnsSubscriptionId = 'daf89b62-86a4-4655-a729-38f72e5069a6'

param deployProject = true

param projectName = 'project'

param projectDescription = 'A project for the AI Foundry account with network secured deployed Agent'

param projectDisplayName = 'network secured agent project'

param existingAiSearchResourceName = 'aisearchhgdemo'

param existingAzureCosmosDBAccountResourceName = 'cosmoshg77'

param existingAzureStorageAccountResourceName = 'strhg22'
