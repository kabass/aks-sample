variable resource_group_name {
  default = "poc-aks-tf-rg"
}

variable location {
  default = "East US"
}

variable storage_account_name {
  default = "pocakstfbackend"
}

variable container_name {
  default = "tfstate"
}
