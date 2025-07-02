using 'main.bicep'

param aiServices = 'aifoundryhg76'

param existingVnetName = 'vnet-agent'

param existingVnetResourceGroupName = 'rg-agent-existing'

param location = 'eastus2'

param existingAgentSubnetName = 'snet-agent'

param existingPeSubnetName = 'snet-pe'

param aiServicesPrivateDnsZoneResourceName = 'privatelink.services.ai.azure.com'

param cognitiveServicesPrivateDnsZoneResourceName = 'privatelink.cognitiveservices.azure.com'

param openAiPrivateDnsZoneResourceName = 'privatelink.openai.azure.com'

param privateDnsResourceGroupName = 'rg-private-dns-zone'

param privateDnsSubscriptionId = 'daf89b62-86a4-4655-a729-38f72e5069a6'

param projectName = 'project'

param projectDescription = 'A project for the AI Foundry account with network secured deployed Agent'

param projectDisplayName = 'network secured agent project'

param existingAiSearchResourceName = 'aisearchhgdemo'

param existingAzureCosmosDBAccountResourceName = 'cosmoshg77'

param existingAzureStorageAccountResourceName = 'strhg22'
