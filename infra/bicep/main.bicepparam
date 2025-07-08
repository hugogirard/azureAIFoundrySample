using 'main.bicep'

param existingVnetName = '__existingVnetName__'

param existingVnetResourceGroupName = '__existingVnetResourceGroupName__'

param location = '__location__'

param existingAgentSubnetName = '__existingAgentSubnetName__'

param existingPeSubnetName = '__existingPeSubnetName__'

param aiServicesPrivateDnsZoneResourceName = '__aiServicesPrivateDnsZoneResourceName__'

param cognitiveServicesPrivateDnsZoneResourceName = '__cognitiveServicesPrivateDnsZoneResourceName__'

param openAiPrivateDnsZoneResourceName = '__openAiPrivateDnsZoneResourceName__'

param privateDnsResourceGroupName = '__privateDnsResourceGroupName__'

param privateDnsSubscriptionId = '__privateDnsSubscriptionId__'

param deployProject = true

param projectName = '__projectName__'

param projectDescription = '__projectDescription__'

param projectDisplayName = '__projectDisplayName__'

param existingAiSearchResourceName = '__existingAiSearchResourceName__'

param existingAzureCosmosDBAccountResourceName = '__existingAzureCosmosDBAccountResourceName__'

param existingAzureStorageAccountResourceName = '__existingAzureStorageAccountResourceName__'

param privateFoundry = true
