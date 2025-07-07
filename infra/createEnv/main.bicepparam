using 'main.bicep'

param location = 'eastus2'

param resourceGroupName = 'rg-fresh-agent'

param subnetAgentAddressPrefix = '192.168.1.0/24'

param subnetJumpboxAddressPrefix = '192.168.3.0/28'

param subnetPrivateEndpointAddressPrefix = '192.168.2.0/27'

param vnetAddressPrefix = '192.168.0.0/16'

param adminPassword = 'blackberry01&'

param adminUserName = 'pladmin'
