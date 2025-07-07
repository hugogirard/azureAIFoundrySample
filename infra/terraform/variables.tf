variable "subscription_id_resources" {
  description = "The subscription id where the resources will be deployed"
  type        = string
  default     = "6e37307e-394c-478a-8404-4e441b3dfc1d"
}

variable "subscription_id_private_dns_zones" {
  description = "The subscription id where the private DNS zones are hosted"
  type        = string
  default     = "6e37307e-394c-478a-8404-4e441b3dfc1d"
}

variable "resource_group_name_dns" {
  description = "The resource group where all the Private DNS Zones resources are located"
  type        = string
  default     = "rg-fresh-agent"
}

variable "private_dns_cognitiveservices_name" {
  description = "The name of the Azure Private DNS Zone for Cognitive Services"
  type        = string
  default     = "privatelink.cognitiveservices.azure.com"
}

variable "private_dns_services_ai_name" {
  description = "The name of the Azure Private DNS Zone for AI Services"
  type        = string
  default     = "privatelink.services.ai.azure.com"
}

variable "private_dns_openai_name" {
  description = "The name of the Azure Private DNS Zone for OpenAI Services"
  type        = string
  default     = "privatelink.openai.azure.com"
}

variable "location" {
  description = "The name of the location to provision the resources to"
  type        = string
  default     = "eastus2"
}

variable "existing_vnet_name" {
  description = "The name of the VNET that will contains the AI Foundry resources"
  type        = string
  default     = "vnet-ai"
}

variable "existing_subnet_agent_name" {
  description = "The name of the subnet that will contains the agents"
  type        = string
  default     = "snet-agent"
}

variable "existing_subnet_private_endpoint_name" {
  description = "The name of the subnet that will contains the private endpoints"
  type        = string
  default     = "snet-pe"
}

variable "resource_group_name_resources" {
  description = "The name of the existing resource group to deploy the resources into"
  type        = string
  default     = "rg-fresh-agent"
}

variable "existing_storage_account_name" {
  description = "The name of the existing storage account to use for agent data"
  type        = string
  default     = "strlpbq74kwlx7m2"
}

variable "existing_cosmosdb_account_name" {
  description = "The name of the existing cosmosdb account to use for agent data"
  type        = string
  default     = "cosmos-lpbq74kwlx7m2"
}

variable "existing_aisearch_account_name" {
  description = "The name of the existing ai search account to use for agent data"
  type        = string
  default     = "search-lpbq74kwlx7m2"
}

variable "ai_foundry_resource_name" {
  description = "The name of the AI Foundry resource"
  type        = string
  default     = "hugifoundry"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "acasol"
}

variable "project_display_name" {
  description = "The display name of the project"
  type        = string
  default     = "acasol"
}

variable "project_description" {
  description = "The description of the project"
  type        = string
  default     = "A project for the AI Foundry account with network secured deployed Agent"
}
