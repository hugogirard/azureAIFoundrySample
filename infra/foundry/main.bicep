param location string
// param vnetResourceName string
// param vnetResourceGroupName string
param subnetAgentResourceId string
// param subnetPrivateEndpointResourceName string
// param aiServicesPrivateDnsZoneResourceName string
// param cognitiveServicesPrivateDnsZoneResourceName string
// param openAiPrivateDnsZoneResourceName string
// param privateDnsResourceGroupName string
// param aiSearchResourceName string
// param azureCosmosDBAccountResourceName string
// param storageAccountResourceName string

var suffix = uniqueString(resourceGroup().id)

var accountName = 'ai-${suffix}'
var networkInjection = 'true'

#disable-next-line BCP036
resource account 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: accountName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: accountName
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Disabled'
    networkInjections: ((networkInjection == 'true')
      ? [
          {
            scenario: 'agent'
            subnetArmId: subnetAgentResourceId
            useMicrosoftManagedNetwork: false
          }
        ]
      : null)
    // true is not supported today
    disableLocalAuth: false
  }
}
