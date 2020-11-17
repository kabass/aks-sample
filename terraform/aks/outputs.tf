output client_id {
  value = azurerm_kubernetes_cluster.k8s_cluster.kubelet_identity[0].client_id
}
