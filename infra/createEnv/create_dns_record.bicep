param privateDnsZoneName string
param recordName string
param ipv4Address string

resource dns 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDnsZoneName
}

resource aRecored 'Microsoft.Network/privateDnsZones/A@2024-06-01' = {
  parent: dns
  name: recordName
  properties: {
    aRecords: [
      {
        ipv4Address: ipv4Address
      }
    ]
    ttl: 10
  }
}
