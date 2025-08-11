param location string
param subnetAgentResourceId string
param subnetPrivateEndpointResourceId string
param openAiDnsZoneName string
param privateDNSResourceGroupName string
param cognitiveServicesDnsZoneName string
param aiServiceDnsZoneName string
param lockdown bool

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
    publicNetworkAccess: lockdown ? 'Disabled' : 'Enabled'
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

/* -------------------------------------------- AI Foundry Account Private Endpoint -------------------------------------------- */

// Private endpoint for AI Services account
// - Creates network interface in customer hub subnet
// - Establishes private connection to AI Services account
resource aiAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${accountName}-private-endpoint'
  location: resourceGroup().location
  properties: {
    subnet: { id: subnetPrivateEndpointResourceId } // Deploy in customer hub subnet
    privateLinkServiceConnections: [
      {
        name: '${accountName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: account.id
          groupIds: ['account'] // Target AI Services account
        }
      }
    ]
  }
}

// Reference existing private DNS zone if provided

resource existingAiServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: aiServiceDnsZoneName
  scope: resourceGroup(privateDNSResourceGroupName)
}

resource existingOpenAiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: openAiDnsZoneName
  scope: resourceGroup(privateDNSResourceGroupName)
}

resource existingCognitiveServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: cognitiveServicesDnsZoneName
  scope: resourceGroup(privateDNSResourceGroupName)
}

// ---- DNS Zone Groups ----
resource aiServicesDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: aiAccountPrivateEndpoint
  name: '${accountName}-dns-group'
  properties: {
    privateDnsZoneConfigs: [
      { name: '${accountName}-dns-aiserv-config', properties: { privateDnsZoneId: existingAiServicePrivateDnsZone.id } }
      { name: '${accountName}-dns-openai-config', properties: { privateDnsZoneId: existingOpenAiPrivateDnsZone.id } }
      {
        name: '${accountName}-dns-cogserv-config'
        properties: { privateDnsZoneId: existingCognitiveServicesPrivateDnsZone.id }
      }
    ]
  }
  dependsOn: []
}

output foundryResourceName string = account.name
