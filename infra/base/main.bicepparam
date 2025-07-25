using 'main.bicep'

param location = '__location__'

param resourceGroupNameVNET = '__resourceGroupNameVNET__'

param resourceGroupName = '__resourceGroupName__'

param sharedServiceResourceGroupName = '__sharedServiceResourceGroupName__'

param subnetAgentAddressPrefix = '__subnetAgentAddressPrefix__'

param subnetJumpboxAddressPrefix = '__subnetJumpboxAddressPrefix__'

param subnetPrivateEndpointAddressPrefix = '__subnetPrivateEndpointAddressPrefix__'

param vnetAddressPrefix = '__vnetAddressPrefix__'

param adminPassword = ''

param adminUserName = ''

param deployApim = true

param publisherEmail = '__publisherEmail__'

param publisherName = '__publisherName__'

param apimSubnetAddressPrefix = '__apimSubnetAddressPrefix__'
