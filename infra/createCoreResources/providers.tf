# Setup providers
provider "azapi" {
  storage_use_azuread = true
}

provider "azurerm" {
  subscription_id = var.subscription_id_resources
  features {}
  storage_use_azuread = true
}