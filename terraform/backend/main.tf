resource "azurerm_resource_group" "tf_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "stor_acc" {
  name                     = "tfbackendpocstoracc"
  resource_group_name      = azurerm_resource_group.tf_rg.name
  location                 = azurerm_resource_group.tf_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "POC AKS"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.stor_acc.name
  container_access_type = "private"
}
