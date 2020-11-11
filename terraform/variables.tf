variable "client_id" {
}
variable "client_secret" {}

variable "agent_count" {
  default = 2
}

variable "dns_prefix" {
  default = "pocaksdns"
}

variable cluster_name {
  default = "poc_aks_cluster"
}



variable resource_group_name {
  default = "poc_aks_rg"
}

variable location {
  default = "East US"
}

variable log_analytics_workspace_name {
  default = "pocAksLoganalytic"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
  default = "PerGB2018"
}


### to change

variable "ssh_public_key" {
  default = "../pki/pocaks.pub"
}
