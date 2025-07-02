param accountName string
param location string
param agentSubnetId string
param privateEndpointSubnetId string

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
            subnetArmId: agentSubnetId
            useMicrosoftManagedNetwork: false
          }
        ]
      : null)
    // true is not supported today
    disableLocalAuth: false
  }
}

/*
   Creating the private endpoint for the Azure AI Foundry
*/
resource aiAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${account.name}-private-endpoint'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: privateEndpointSubnetId // Deploy in customer hub subnet
    }
    privateLinkServiceConnections: [
      {
        name: '${account.name}-private-link-service-connection'
        properties: {
          privateLinkServiceId: account.id
          groupIds: [
            'account' // Target AI Services account
          ]
        }
      }
    ]
  }
}

output accountName string = account.name
output accountID string = account.id
output accountTarget string = account.properties.endpoint
output accountPrincipalId string = account.identity.principalId
output privateEndpointPrivateIP string = aiAccountPrivateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]
