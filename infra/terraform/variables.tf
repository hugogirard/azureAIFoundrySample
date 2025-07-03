variable "subscription_id_resources" {
  description = "The subscription id where the resources will be deployed"
  type        = string
  default     = "6e37307e-394c-478a-8404-4e441b3dfc1d"
}

variable "subscription_id_private_dns_zones" {
  description = "The subscription id where the private DNS zones are hosted"
  type        = string
  default     = "daf89b62-86a4-4655-a729-38f72e5069a6"
}

variable "resource_group_name_dns" {
    description = "The resource group where all the Private DNS Zones resources are located"
    type        = string
    default     = "rg-private-dns-zone"
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
  default = "strhgtest77"
}

variable "existing_cosmosdb_account_name" {
    description = "The name of the existing cosmosdb account to use for agent data"
    type = string
    default = "cosmosdbhg77"
}

variable "existing_aisearch_account_name" {
    description = "The name of the existing ai search account to use for agent data"
    type = string
    default = "aisearchhg"
}

variable "ai_foundry_resource_name" {
    description = "The name of the AI Foundry resource"
    type        = string
    default     = "aihgfoundry37"
}

variable "subnet_id_agent" {
    description = "The resource id of the subnet that has been delegated to Microsoft.Apps/environments"
    type        = string
    default     = "/subscriptions/6e37307e-394c-478a-8404-4e441b3dfc1d/resourceGroups/rg-agent-existing/providers/Microsoft.Network/virtualNetworks/vnet-agent/subnets/snet-agent"
}

variable  "subnet_id_pe" {
  description = "The resource id of the subnet that will contains the private endpoint of foundry"
  type        = string
  default     = "/subscriptions/6e37307e-394c-478a-8404-4e441b3dfc1d/resourceGroups/rg-agent-existing/providers/Microsoft.Network/virtualNetworks/vnet-agent/subnets/snet-pe"  
}

variable "project_name" {
    description = "The name of the project"
    type        = string
    default     = "cont"
}



