variable "subscription_id_resources" {
  description = "The subscription id where the resources will be deployed"
  type        = string
  default     = "__subscription_id_resources__"
}

variable "location" {
  description = "The location where the core resources will be created"
  type        = string
  default     = "__location__"
}

variable "resource_group_name_vnet" {
  description = "The name of the resource group for the VNET"
  type        = string
  default     = "__resource_group_name_vnet__"
}

variable "resource_group_name" {
  description = "The name of the resource group for the Azure agent demo"
  type        = string
  default     = "__resource_group_name__"
}

variable "resource_group_tf_state" {
  description = "The name of the resource group for Terraform state"
  type        = string
  default     = "__resource_group_tf_state__"
}

variable "subnet_agent_address_prefix" {
  description = "The address prefix for the agent subnet"
  type        = string
  default     = "__subnet_agent_address_prefix__"
}

variable "subnet_jumpbox_address_prefix" {
  description = "The address prefix for the jumpbox subnet"
  type        = string
  default     = "__subnet_jumpbox_address_prefix__"
}

variable "subnet_private_endpoint_address_prefix" {
  description = "The address prefix for the private endpoint subnet"
  type        = string
  default     = "__subnet_private_endpoint_address_prefix__"
}

variable "vnet_address_prefix" {
  description = "The address prefix for the virtual network"
  type        = string
  default     = "__vnet_address_prefix__"
}

variable "admin_password" {
  description = "The administrator password"
  type        = string
  default     = "__adminPassword__"
}

variable "admin_username" {
  description = "The administrator username"
  type        = string
  default     = "__adminUserName__"
}

variable "deploy_apim" {
  description = "Deploy Azure Api Management"
  type        = bool
  default     = "__deploy_apim__"
}