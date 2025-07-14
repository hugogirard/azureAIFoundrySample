variable "subscription_id_resources" {
  description = "The subscription id where the resources will be deployed"
  type        = string
  default     = "6e37307e-394c-478a-8404-4e441b3dfc1d"
}

variable "location" {
  description = "The location where the core resources will be created"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name_vnet" {
  description = "The name of the resource group for the VNET"
  type        = string
  default     = "rg-vnet-agent"
}

variable "resource_group_name" {
  description = "The name of the resource group for the Azure agent demo"
  type        = string
  default     = "rg-azure-agent-demo"
}

variable "resource_group_tf_state" {
  description = "The name of the resource group for Terraform state"
  type        = string
  default     = "rg-tf-state"
}

variable "subnet_agent_address_prefix" {
  description = "The address prefix for the agent subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "subnet_jumpbox_address_prefix" {
  description = "The address prefix for the jumpbox subnet"
  type        = string
  default     = "192.168.3.0/28"
}

variable "subnet_private_endpoint_address_prefix" {
  description = "The address prefix for the private endpoint subnet"
  type        = string
  default     = "192.168.2.0/27"
}

variable "vnet_address_prefix" {
  description = "The address prefix for the virtual network"
  type        = string
  default     = "192.168.0.0/16"
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
  default     = false
}