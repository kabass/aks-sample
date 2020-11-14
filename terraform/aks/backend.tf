terraform {
  backend "azurerm" {
    resource_group_name  = "poc-aks-tf-rg"
    storage_account_name = "tfbackendpocstoracc"
    container_name       = "tfstate"
    key                  = "poc.terraform.tfstate"
  }
}
/*
data "terraform_remote_state" "foo" {
  backend = "azurerm"
  config = {
    resource_group_name  = "poc-aks-tf-rg"
    storage_account_name = "tfbackendpocstoracc"
    container_name       = "tfstate"
    key                  = "poc.terraform.tfstate"
  }
}
*/