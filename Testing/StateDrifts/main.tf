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

  count = var.workspace_var

  tags = var.default_tags
}

resource "azurerm_storage_share" "storage_share" {
  name                 = "storage"
  storage_account_name = azurerm_storage_account.sharedStorage[count.index].name
  quota                = 2048

  count = var.workspace_var
}