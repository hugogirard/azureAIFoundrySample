########## Create infrastructure resources
##########

## Reference an existing dependent
## resources

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

data "azapi_resource" "ai_search" {
  provider = azapi.workload_subscription
  
  name                = var.existing_aisearch_account_name
  parent_id           = "/subscriptions/${var.subscription_id_resources}/resourceGroups/${var.resource_group_name_resources}"
  type                = "Microsoft.Search/searchServices@2024-06-01-preview"
}

## Create the AI Foundry resource
##
resource "azapi_resource" "ai_foundry" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.CognitiveServices/accounts@2025-04-01-preview"
  name                      = var.ai_foundry_resource_name
  parent_id                 = "/subscriptions/${var.subscription_id_resources}/resourceGroups/${var.resource_group_name_resources}"
  location                  = var.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices",
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }

    properties = {

      # Support both Entra ID and API Key authentication for underlining Cognitive Services account
      disableLocalAuth = false

      # Specifies that this is an AI Foundry resource
      allowProjectManagement = true

      # Set custom subdomain name for DNS names created for this Foundry resource
      customSubDomainName    = var.ai_foundry_resource_name

      # Network-related controls
      # Disable public access but allow Trusted Azure Services exception
      publicNetworkAccess = "Disabled"
      networkAcls = {
        defaultAction = "Allow"
      }

      # Enable VNet injection for Standard Agents
      networkInjections = [
        {
          scenario                   = "agent"
          subnetArmId                = var.subnet_id_agent
          useMicrosoftManagedNetwork = false
        }
      ]
    }
  }
}

########## Create Private Endpoint Foundry
##########
resource "azurerm_private_endpoint" "pe-aifoundry" {
  provider = azurerm.workload_subscription

  depends_on = [    
    azapi_resource.ai_foundry
  ]

  name                = "${azapi_resource.ai_foundry.name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name_resources
  subnet_id           = var.subnet_id_pe

  private_service_connection {
    name                           = "${azapi_resource.ai_foundry.name}-private-link-service-connection"
    private_connection_resource_id = azapi_resource.ai_foundry.id
    subresource_names = [
      "account"
    ]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "${azapi_resource.ai_foundry.name}-dns-config"
    private_dns_zone_ids = [
      "/subscriptions/${var.subscription_id_private_dns_zones}/resourceGroups/${var.resource_group_name_dns}/providers/Microsoft.Network/privateDnsZones/${var.private_dns_cognitiveservices_name}",
      "/subscriptions/${var.subscription_id_private_dns_zones}/resourceGroups/${var.resource_group_name_dns}/providers/Microsoft.Network/privateDnsZones/${var.private_dns_services_ai_name}",
      "/subscriptions/${var.subscription_id_private_dns_zones}/resourceGroups/${var.resource_group_name_dns}/providers/Microsoft.Network/privateDnsZones/${var.private_dns_openai_name}"
    ]
  }
}

########## Create the AI Foundry project, project connections, role assignments, and project-level capability host
##########

## Create AI Foundry project
##
resource "azapi_resource" "ai_foundry_project" {
  provider = azapi.workload_subscription

  depends_on = [
    azapi_resource.ai_foundry
  ]

  type                      = "Microsoft.CognitiveServices/accounts/projects@2024-10-01-preview"
  name                      = "${var.project_name}"
  parent_id                 = azapi_resource.ai_foundry.id
  location                  = var.location
  schema_validation_enabled = false

  body = {
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }

    properties = {
      displayName = "${var.project_name}"
      description = "A project for the AI Foundry account"
    }
  }

  response_export_values = [
    "identity.principalId",
    "properties.internalId"
  ]
}

## Wait 10 seconds for the AI Foundry project system-assigned managed identity to be created and to replicate
## through Entra ID
resource "time_sleep" "wait_project_identities" {
  depends_on = [
    azapi_resource.ai_foundry_project
  ]
  create_duration = "10s"
}

## Create AI Foundry project connections
##
resource "azapi_resource" "conn_cosmosdb" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name                      = data.azurerm_cosmosdb_account.cosmosdb.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = data.azurerm_cosmosdb_account.cosmosdb.name
    properties = {
      category = "CosmosDB"
      target   = data.azurerm_cosmosdb_account.cosmosdb.endpoint
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = data.azurerm_cosmosdb_account.cosmosdb.id
        location   = var.location
      }
    }
  }
}

## Create the AI Foundry project connection to Azure Storage Account
##
resource "azapi_resource" "conn_storage" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name                      = data.azurerm_storage_account.storage_account.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = data.azurerm_storage_account.storage_account.name
    properties = {
      category = "AzureStorageAccount"
      target   = data.azurerm_storage_account.storage_account.primary_blob_endpoint
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = data.azurerm_storage_account.storage_account.id
        location   = var.location
      }
    }
  }

  response_export_values = [
    "identity.principalId"
  ]
}

## Create the AI Foundry project connection to AI Search
##
resource "azapi_resource" "conn_aisearch" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name                      = data.azapi_resource.ai_search.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = data.azapi_resource.ai_search.name
    properties = {
      category = "CognitiveSearch"
      target   = "https://${data.azapi_resource.ai_search.name}.search.windows.net"
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ApiVersion = "2024-05-01-preview"
        ResourceId = data.azapi_resource.ai_search.id
        location   = var.location
      }
    }
  }

  response_export_values = [
    "identity.principalId"
  ]
}