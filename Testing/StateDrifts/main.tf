provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "general-rg" {
  location = var.azure_region
  name     = "${var.cust}-${var.app_name}-${var.environment}-rg"
  tags     = var.default_tags
}

resource "azurerm_virtual_network" "workspace" {
  name                = "${var.app_name}-${var.environment}-vnet"
  location            = azurerm_resource_group.general-rg.location
  resource_group_name = azurerm_resource_group.general-rg.name
  address_space       = ["10.252.${var.address_space}.0/23"]
  dns_servers         = ["10.252.3.4", "10.254.3.5"]

  tags = var.default_tags
}

resource "azurerm_subnet" "workspace_subnet" {
  name                 = "${var.app_name}-${var.environment}-workspace-subnet"
  resource_group_name  = azurerm_resource_group.general-rg.name
  virtual_network_name = azurerm_virtual_network.workspace.name
  address_prefixes     = ["10.252.${var.address_space}.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "random_id" "randomId" {
  keepers = {
    resource_group = azurerm_resource_group.general-rg.name
  }
  count       = var.workspace_var
  byte_length = 8
}

resource "azurerm_storage_account" "sharedStorage" {
  name                      = "input${lower(random_id.randomId[count.index].hex)}"
  resource_group_name       = azurerm_resource_group.general-rg.name
  location                  = var.azure_region
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  queue_encryption_key_type = "Service"
  shared_access_key_enabled = true
  table_encryption_key_type = "Service"

  blob_properties {
    change_feed_enabled      = false
    last_access_time_enabled = false
    versioning_enabled       = false
  }

  share_properties {
    retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["83.86.209.118", ]
    virtual_network_subnet_ids = ["/subscriptions/7988622a-fe45-422d-aba5-7f2fa1d45f89/resourceGroups/mja-tryout-tst-rg/providers/Microsoft.Network/virtualNetworks/tryout-tst-vnet/subnets/tryout-tst-workspace-subnet", ]
  }

  count = var.workspace_var

  tags = var.default_tags

}

resource "azurerm_storage_share" "storage_share" {
  name                 = "storage"
  storage_account_name = azurerm_storage_account.sharedStorage[count.index].name
  quota                = 2048

  count = var.workspace_var
}