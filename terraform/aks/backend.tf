terraform {
  backend "azurerm" {
    resource_group_name  = "poc-aks-tf-rg"
    storage_account_name = "pocakstfbackend"
    container_name       = "tfstate"
    key                  = "poc-aks.tfstate"
  }
}
