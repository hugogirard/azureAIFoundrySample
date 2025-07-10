variable "subscription_id_resources" {
  description = "The subscription id where the resources will be deployed"
  type        = string
}

variable "subscription_id_private_dns_zones" {
  description = "The subscription id where the private DNS zones are hosted"
  type        = string
}

variable "resource_group_name_dns" {
  description = "The resource group where all the Private DNS Zones resources are located"
  type        = string
}

variable "vnet_resource_group_name" {
  description = "The resource group where all the vnet is located"
  type        = string
}

variable "private_dns_cognitiveservices_name" {
  description = "The name of the Azure Private DNS Zone for Cognitive Services"
  type        = string
}

variable "private_dns_services_ai_name" {
  description = "The name of the Azure Private DNS Zone for AI Services"
  type        = string
}

variable "private_dns_openai_name" {
  description = "The name of the Azure Private DNS Zone for OpenAI Services"
  type        = string
}

variable "location" {
  description = "The name of the location to provision the resources to"
  type        = string
}

variable "existing_vnet_name" {
  description = "The name of the VNET that will contains the AI Foundry resources"
  type        = string
}

variable "existing_subnet_agent_name" {
  description = "The name of the subnet that will contains the agents"
  type        = string
}

variable "existing_subnet_private_endpoint_name" {
  description = "The name of the subnet that will contains the private endpoints"
  type        = string
}

variable "resource_group_name_resources" {
  description = "The name of the existing resource group to deploy the resources into"
  type        = string
}

variable "existing_storage_account_name" {
  description = "The name of the existing storage account to use for agent data"
  type        = string
}

variable "existing_cosmosdb_account_name" {
  description = "The name of the existing cosmosdb account to use for agent data"
  type        = string
}

variable "existing_aisearch_account_name" {
  description = "The name of the existing ai search account to use for agent data"
  type        = string
}

variable "ai_foundry_resource_name" {
  description = "The name of the AI Foundry resource"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "project_display_name" {
  description = "The display name of the project"
  type        = string
}

variable "project_description" {
  description = "The description of the project"
  type        = string
}
