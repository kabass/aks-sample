variable "client_id" {}

variable "client_secret" {}

variable resource_group_name {
  default = "poc-aks-tf-rg"
}

variable location {
  default = "East US"
}
