variable "subscription_id_resources" {
  description = "The subscription id where the resources will be deployed"
  type        = string
  default     = "6e37307e-394c-478a-8404-4e441b3dfc1d"
}

variable "location" {
  description = "The name of the location to provision the resources to"
  type        = string
  default = "eastus2"
}

variable "resource_group_name_resources" {
  description = "The name of the existing resource group to deploy the resources into"
  type        = string
  default     = "rg-agent-existing"
}

variable "existing_storage_account_name" {
  description = "The name of the existing storage account to use for agent data"
  type        = string
  default = "strhg22"
}

variable "existing_cosmosdb_account_name" {
    description = "The name of the existing cosmosdb account to use for agent data"
    type = string
    default = "cosmoshg77"
}