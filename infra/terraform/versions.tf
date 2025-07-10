# Configure the AzApi and AzureRM providers
terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.3.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }
  required_version = ">= 1.8.3"
  # Comment when running locally to not store state in Azure Storage
  backend "azurerm" {
    resource_group_name  = "__resourceGroupName__"
    storage_account_name = "__storageAccountName__"
    container_name       = "tfstate"
    key                  = "foundry.tfstate"
    tenant_id            = "__tenantID__"
    subscription_id      = "__subscriptionID__"
  }
}
