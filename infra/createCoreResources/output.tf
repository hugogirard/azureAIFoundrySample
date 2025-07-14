output "resourceGroupName" {
  value = azurerm_resource_group.rg_resources.name
}

output "location" {
  value = var.location
}

output "vnetResourceName" {
  value = azurerm_virtual_network.vnet.name
}

output "vnetResourceGroupName" {
  value = azurerm_resource_group.rg_vnet.name
}

output "subnetAgentResourceName" {
  value = azurerm_subnet.subnet_agent.name
}

output "subnetPrivateEndpointResourceName" {
  value = azurerm_subnet.subnet_pe.name
}

output "aiServicesPrivateDnsZoneResourceName" {
  value = azurerm_private_dns_zone.plz_ai_services.name
}

output "cognitiveServicesPrivateDnsZoneResourceName" {
  value = azurerm_private_dns_zone.plz_cognitive_services.name
}

output "openAiPrivateDnsZoneResourceName" {
  value = azurerm_private_dns_zone.plz_openai.name
}

output "privateDnsResourceGroupName" {
  value = azurerm_resource_group.rg_vnet.name
}

output "aiSearchResourceName" {
  value = azapi_resource.ai_search.name
}

output "azureCosmosDBAccountResourceName" {
  value = azurerm_cosmosdb_account.cosmosdb.name
}

output "storageAccountResourceName" {
  value = azurerm_storage_account.storage_account.name
}