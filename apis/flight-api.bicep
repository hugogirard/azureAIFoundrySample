param apimResourceName string
param flightApiEndpoint string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimResourceName
}

resource flight_api 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'flight-api'
  properties: {
    apiRevision: '1'
    isCurrent: true
    subscriptionRequired: true
    displayName: 'FlightApi'
    format: 'openapi+json'
    value: loadTextContent('../src/apis/flight-api/openapi.json')
    serviceUrl: flightApiEndpoint
    path: 'fl'
    protocols: [
      'https'
    ]
  }
}
