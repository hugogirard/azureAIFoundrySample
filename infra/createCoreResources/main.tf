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

# Resource group creations
resource "azurerm_resource_group" "rg_vnet" {
  name     = var.resource_group_name_vnet
  location = var.location
}

resource "azurerm_resource_group" "rg_resources" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "rg_tf_state" {
  name     = var.resource_group_tf_state
  location = var.location
}

# Networking
resource "azurerm_network_security_group" "nsg_jumpbox" {
  name                = "nsg-jumpbox"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ai"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_resources.name
  address_space       = [var.vnet_address_prefix]

  subnet {
    name             = "snet-jumpbox"
    address_prefixes = [var.subnet_jumpbox_address_prefix]
    security_group   = azurerm_network_security_group.nsg_jumpbox.id
  }
}

resource "azurerm_subnet" "subnet_agent" {
  name                 = "snet-agent"
  resource_group_name  = azurerm_resource_group.rg_resources.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [
    var.subnet_agent_address_prefix
  ]
  delegation {
    name = "Microsoft.App/environments"
    service_delegation {
      name = "Microsoft.App/environments"
    }
  }
}

resource "azurerm_subnet" "subnet_pe" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.rg_resources.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [
    var.subnet_private_endpoint_address_prefix
  ]
}

########## Create resoures required to store agent data
##########

## Create a storage account for agent data
##
resource "azurerm_storage_account" "storage_account" {
  name                = "aifoundry${random_string.unique.result}storage"
  resource_group_name = azurerm_resource_group.rg_resources.name
  location            = var.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  ## Identity configuration
  shared_access_key_enabled = false

  ## Network access configuration
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  network_rules {
    default_action = "Deny"
    bypass = [
      "AzureServices"
    ]
  }
}

## Create the Cosmos DB account to store agent threads
##
resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "aifoundry${random_string.unique.result}cosmosdb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_resources.name

  # General settings
  offer_type        = "Standard"
  kind              = "GlobalDocumentDB"
  free_tier_enabled = false

  # Set security-related settings
  local_authentication_disabled = true
  public_network_access_enabled = false

  # Set high availability and failover settings
  automatic_failover_enabled       = false
  multiple_write_locations_enabled = false

  # Configure consistency settings
  consistency_policy {
    consistency_level = "Session"
  }

  # Configure single location with no zone redundancy to reduce costs
  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = false
  }
}

## Create an AI Search instance that will be used to store vector embeddings
##
resource "azapi_resource" "ai_search" {
  type                      = "Microsoft.Search/searchServices@2024-06-01-preview"
  name                      = "aifoundry${random_string.unique.result}search"
  parent_id                 = azurerm_resource_group.rg_resources.id
  location                  = var.location
  schema_validation_enabled = true

  body = {
    sku = {
      name = "standard"
    }

    identity = {
      type = "SystemAssigned"
    }

    properties = {

      # Search-specific properties
      replicaCount   = 1
      partitionCount = 1
      hostingMode    = "default"
      semanticSearch = "disabled"

      # Identity-related controls
      disableLocalAuth = false
      authOptions = {
        aadOrApiKey = {
          aadAuthFailureMode = "http401WithBearerChallenge"
        }
      }
      # Networking-related controls
      publicNetworkAccess = "disabled"
      networkRuleSet = {
        bypass = "None"
      }
    }
  }
}

## Create required Private DNS Zones
##
resource "azurerm_private_dns_zone" "plz_cosmos_db" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone" "plz_ai_search" {
  name                = "privatelink.search.windows.net"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone" "plz_storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone" "plz_cognitive_services" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone" "plz_ai_services" {
  name                = "privatelink.services.ai.azure.com"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone" "plz_openai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

## Create Private DNS Zone Links to link the Private DNS Zones to the virtual network
##
resource "azurerm_private_dns_zone_virtual_network_link" "plz_cosmos_db_link" {
  depends_on = [
    azurerm_private_dns_zone.plz_cosmos_db,
    azurerm_virtual_network.vnet
  ]
  name                  = "cosmosdb-${random_string.unique.result}-link"
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.plz_cosmos_db.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "plz_ai_search_link" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.plz_cosmos_db_link,
    azurerm_private_dns_zone.plz_ai_search,
    azurerm_virtual_network.vnet
  ]

  name                  = "aisearch-${random_string.unique.result}-link"
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.plz_ai_search.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "plz_storage_blob_link" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.plz_ai_search_link,
    azurerm_private_dns_zone.plz_storage_blob,
    azurerm_virtual_network.vnet
  ]
  name                  = "storage-${random_string.unique.result}-link"
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.plz_storage_blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "plz_cognitive_services_link" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.plz_storage_blob_link,
    azurerm_private_dns_zone.plz_cognitive_services,
    azurerm_virtual_network.vnet
  ]
  name                  = "cogsvc-${random_string.unique.result}-link"
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.plz_cognitive_services.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "plz_ai_services_link" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.plz_cognitive_services_link,
    azurerm_private_dns_zone.plz_ai_services,
    azurerm_virtual_network.vnet
  ]
  name                  = "aiservices-${random_string.unique.result}-link"
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.plz_ai_services.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "plz_openai_link" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.plz_ai_services_link,
    azurerm_private_dns_zone.plz_openai,
    azurerm_virtual_network.vnet
  ]
  name                  = "openai-${random_string.unique.result}-link"
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.plz_openai.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

## Create Private Endpoints for resources
##
resource "azurerm_private_endpoint" "pe-storage" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.plz_ai_search_link,
    azurerm_private_dns_zone_virtual_network_link.plz_storage_blob_link,
    azurerm_private_dns_zone_virtual_network_link.plz_cognitive_services_link,
    azurerm_private_dns_zone_virtual_network_link.plz_ai_services_link,
    azurerm_private_dns_zone_virtual_network_link.plz_openai_link,
    azurerm_private_dns_zone_virtual_network_link.plz_cosmos_db_link,
    azurerm_storage_account.storage_account,
    azurerm_virtual_network.vnet
  ]

  name                = "${azurerm_storage_account.storage_account.name}-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_resources.name
  subnet_id           = azurerm_subnet.subnet_pe.id

  private_service_connection {
    name                           = "${azurerm_storage_account.storage_account.name}-private-link-service-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names = [
      "blob"
    ]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "${azurerm_storage_account.storage_account.name}-dns-config"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.plz_storage_blob.id
    ]
  }
}

resource "azurerm_private_endpoint" "pe-cosmosdb" {
  depends_on = [
    azurerm_private_endpoint.pe-storage,
    azurerm_cosmosdb_account.cosmosdb,
    azurerm_virtual_network.vnet
  ]

  name                = "${azurerm_cosmosdb_account.cosmosdb.name}-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_resources.name
  subnet_id           = azurerm_subnet.subnet_pe.id

  private_service_connection {
    name                           = "${azurerm_cosmosdb_account.cosmosdb.name}-private-link-service-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmosdb.id
    subresource_names = [
      "Sql"
    ]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "${azurerm_cosmosdb_account.cosmosdb.name}-dns-config"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.plz_cosmos_db.id
    ]
  }
}

resource "azurerm_private_endpoint" "pe-aisearch" {
  depends_on = [
    azurerm_private_endpoint.pe-cosmosdb,
    azapi_resource.ai_search,
    azurerm_virtual_network.vnet
  ]

  name                = "${azapi_resource.ai_search.name}-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_resources.name
  subnet_id           = azurerm_subnet.subnet_pe.id

  private_service_connection {
    name                           = "${azapi_resource.ai_search.name}-private-link-service-connection"
    private_connection_resource_id = azapi_resource.ai_search.id
    subresource_names = [
      "searchService"
    ]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "${azapi_resource.ai_search.name}-dns-config"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.plz_ai_search.id
    ]
  }
}

## Add A records for the jumpbox private endpoint in all private DNS zones
# resource "azurerm_private_dns_a_record" "jumpbox_a_record_cosmosdb" {
#     name                = "jumpbox"
#     zone_name           = azurerm_private_dns_zone.plz_cosmos_db.name
#     resource_group_name = azurerm_resource_group.rg_vnet.name
#     ttl                 = 10
#     records             = [azurerm]
# }

# resource "azurerm_private_dns_a_record" "jumpbox_a_record_ai_search" {
#     name                = "jumpbox"
#     zone_name           = azurerm_private_dns_zone.plz_ai_search.name
#     resource_group_name = azurerm_resource_group.rg_vnet.name
#     ttl                 = 300
#     records             = [azurerm_private_endpoint.pe-aisearch.private_service_connection[0].private_ip_address]
# }

# resource "azurerm_private_dns_a_record" "jumpbox_a_record_storage_blob" {
#     name                = "jumpbox"
#     zone_name           = azurerm_private_dns_zone.plz_storage_blob.name
#     resource_group_name = azurerm_resource_group.rg_vnet.name
#     ttl                 = 300
#     records             = [azurerm_private_endpoint.pe-storage.private_service_connection[0].private_ip_address]
# }

# resource "azurerm_private_dns_a_record" "jumpbox_a_record_cognitive_services" {
#     name                = "jumpbox"
#     zone_name           = azurerm_private_dns_zone.plz_cognitive_services.name
#     resource_group_name = azurerm_resource_group.rg_vnet.name
#     ttl                 = 300
#     records             = [azurerm_private_endpoint.pe-storage.private_service_connection[0].private_ip_address]
# }

# resource "azurerm_private_dns_a_record" "jumpbox_a_record_ai_services" {
#     name                = "jumpbox"
#     zone_name           = azurerm_private_dns_zone.plz_ai_services.name
#     resource_group_name = azurerm_resource_group.rg_vnet.name
#     ttl                 = 300
#     records             = [azurerm_private_endpoint.pe-aisearch.private_service_connection[0].private_ip_address]
# }

# resource "azurerm_private_dns_a_record" "jumpbox_a_record_openai" {
#     name                = "jumpbox"
#     zone_name           = azurerm_private_dns_zone.plz_openai.name
#     resource_group_name = azurerm_resource_group.rg_vnet.name
#     ttl                 = 300
#     records             = [azurerm_private_endpoint.pe-aisearch.private_service_connection[0].private_ip_address]
# }