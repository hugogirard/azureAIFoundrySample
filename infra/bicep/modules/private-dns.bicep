param aiServicesPrivateDnsZoneResourceName string
param openAiPrivateDnsZoneResourceName string
param cognitiveServicesPrivateDnsZoneResourceName string
param privateEndpointIPAIFoundryService string
param aiAccountResourceName string

resource aiServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: aiServicesPrivateDnsZoneResourceName
}

resource openAiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: openAiPrivateDnsZoneResourceName
}

resource cognitiveServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: cognitiveServicesPrivateDnsZoneResourceName
}

// Add the A Record for the AI Foundry
resource aiServicesARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: aiAccountResourceName
  parent: aiServicesPrivateDnsZone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateEndpointIPAIFoundryService
      }
    ]
  }
}

resource openAiARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: aiAccountResourceName
  parent: openAiPrivateDnsZone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateEndpointIPAIFoundryService
      }
    ]
  }
}

resource cognitiveServicesARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: aiAccountResourceName
  parent: cognitiveServicesPrivateDnsZone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateEndpointIPAIFoundryService
      }
    ]
  }
}
