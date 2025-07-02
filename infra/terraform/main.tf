########## Create infrastructure resources
##########

## Create a random string
## 
resource "random_string" "unique" {
  length      = 4
  min_numeric = 4
  numeric     = true
  special     = false
  lower       = true
  upper       = false
}

## Reference an existing storage account for agent data
##

data "azurerm_storage_account" "storage_account" {
  provider = azurerm.workload_subscription

  name                = var.existing_storage_account_name
  resource_group_name = var.resource_group_name_resources
}

data "azurerm_cosmosdb_account" "cosmosdb" {
  provider = azurerm.workload_subscription

  name                = var.existing_cosmosdb_account_name
  resource_group_name = var.resource_group_name_resources
}