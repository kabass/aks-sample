output client_id {
  value = azurerm_kubernetes_cluster.k8s_cluster.kubelet_identity[0].client_id
}

output pod_principal_id {
  value = azurerm_user_assigned_identity.identity.principal_id
}

output pod_client_id {
  value = azurerm_user_assigned_identity.identity.client_id
}
