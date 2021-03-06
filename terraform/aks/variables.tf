variable agent_count {
  default = 2
}

variable pool_name {
  default = "pocakspool"
}

variable dns_prefix {
  default = "pocaksdns"
}

variable cluster_name {
  default = "poc_aks_cluster"
}

variable keyvault_name {
  default = "poc-aks-kv"
}

variable others_resource_group_name {
  default = "poc_aks_others_rg"
}

variable resource_group_name {
  default = "poc_aks_cluster_rg"
}

variable node_resource_group_name {
  default = "poc_aks_nodes_rg"
}

variable location {
  default = "East US"
}

variable pod_identity {
  default = "poc-aks-pod-identity"
}

variable log_analytics_workspace_name {
  default = "pocAksLoganalytic"
}

variable ssh_public_key {
  default = "../../pki/pocaks.pub"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
  default = "PerGB2018"
}

variable kubeconfig {
  default = "~/.kube/config"
}