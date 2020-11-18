provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.36"
  features {}
}

resource "azurerm_resource_group" "tf_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "stor_acc" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.tf_rg.name
  location                 = azurerm_resource_group.tf_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    project = "POC AKS"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.stor_acc.name
  container_access_type = "private"
}
