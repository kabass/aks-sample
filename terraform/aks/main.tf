resource "azurerm_resource_group" "k8s_cluster_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = var.log_analytics_workspace_location
  resource_group_name = var.others_resource_group_name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.test.location
  resource_group_name   = var.others_resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
/*
## Private key for the kubernetes cluster ##
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}
*/

data "azurerm_virtual_network" "vpn" {
  name                = "poc-aks-vnet"
  resource_group_name = "poc-aks-network-rg"
}

resource "azurerm_kubernetes_cluster" "k8s_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.k8s_cluster_rg.location
  resource_group_name = azurerm_resource_group.k8s_cluster_rg.name
  node_resource_group = var.node_resource_group_name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name       = var.pool_name
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"

    #vnet_id         = data.azurerm_virtual_network.vpn.id
    #nodes_subnet_id = data.azurerm_virtual_network.vpn.subnet_ids[0]
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
    load_balancer_sku  = "Standard"
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
    }
  }

  tags = {
    Environment = "Development"
  }
}

resource "null_resource" "csi-secrets-store-provider-azure_aad-pod-identity" {
  depends_on = [azurerm_kubernetes_cluster.k8s_cluster]

  provisioner "local-exec" {
    command = "az aks get-credentials --name ${azurerm_kubernetes_cluster.k8s_cluster.name} --overwrite-existing --resource-group ${azurerm_kubernetes_cluster.k8s_cluster.resource_group_name}"
  }

  provisioner "local-exec" {
    command = "helm repo add csi-secrets-store-provider-azure https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
  }
  provisioner "local-exec" {
    command = "helm install csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --generate-name"
  }

  provisioner "local-exec" {
    command = "helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  }
  provisioner "local-exec" {
    command = "helm install pod-identity aad-pod-identity/aad-pod-identity"
  }
}


### Cluster Identity permissions on Resource groups
resource "azurerm_role_assignment" "Managed_Identity_Operator_cluster" {
  scope                = azurerm_resource_group.k8s_cluster_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.k8s_cluster.identity[0].principal_id
}

data "azurerm_resource_group" "k8s_node_rg" {
  depends_on = [azurerm_kubernetes_cluster.k8s_cluster]
  name       = azurerm_kubernetes_cluster.k8s_cluster.node_resource_group
}

resource "azurerm_role_assignment" "Managed_Identity_Operator_nodes" {
  scope = data.azurerm_resource_group.k8s_node_rg.id

  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.k8s_cluster.identity[0].principal_id
}

resource "azurerm_role_assignment" "Virtual_Machine_Contributor_nodes" {
  scope = data.azurerm_resource_group.k8s_node_rg.id

  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s_cluster.identity[0].principal_id
}


### Pod Identity permissions on KeyVault
resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = var.others_resource_group_name
  location            = var.log_analytics_workspace_location

  name = var.pod_identity
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  resource_group_name = var.others_resource_group_name
}

resource "azurerm_role_assignment" "reader_kv" {
  scope                = data.azurerm_key_vault.keyvault.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_key_vault_access_policy" "identity_get" {
  key_vault_id = data.azurerm_key_vault.keyvault.id

  tenant_id      = data.azurerm_client_config.current.tenant_id
  object_id      = azurerm_user_assigned_identity.identity.client_id
  application_id = azurerm_user_assigned_identity.identity.client_id

  key_permissions = [
    "get",
  ]

  secret_permissions = [
    "get",
  ]
}

/* Not need because the cluster delete will also delete these resources
resource "null_resource" "kubectl_delete" {
  triggers = {
    secretProvider_yaml = local.secretProvider_yaml
    aadpodidentity_yaml =local.aadpodidentity_yaml
  }

  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f - <<EOF\n${self.triggers.secretProvider_yaml}\nEOF"

    interpreter = ["/bin/bash", "-c"]
    on_failure = continue
  }

  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f - <<EOF\n${self.triggers.aadpodidentity_yaml}\nEOF"

    interpreter = ["/bin/bash", "-c"]
    on_failure = continue
  }
}*/

resource "null_resource" "kubectl_apply" {
  triggers = {
    always_run = timestamp()
  }

  depends_on = [azurerm_kubernetes_cluster.k8s_cluster]

  provisioner "local-exec" {
    command     = "kubectl apply -f - <<EOF\n${local.secretProvider_yaml}\nEOF"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    command     = "kubectl apply -f - <<EOF\n${local.aadpodidentity_yaml}\nEOF"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "null_resource" "kubectl_apply_pod" {
  triggers = {
    always_run = timestamp()
    pod_yaml   = local.pod_yaml
  }

  depends_on = [null_resource.kubectl_apply]

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f - <<EOF\n${self.triggers.pod_yaml}\nEOF"

    interpreter = ["/bin/bash", "-c"]
    on_failure  = continue
  }

  provisioner "local-exec" {
    command     = "kubectl apply -f - <<EOF\n${local.pod_yaml}\nEOF"
    interpreter = ["/bin/bash", "-c"]
  }
}


locals {
  secretProvider_yaml = <<EOF
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: poc-aks-registry-secret
spec:
  provider: azure
  parameters:
    usePodIdentity: "true"                                              # [REQUIRED] Set to "true" if using managed identities
    useVMManagedIdentity: "false"                                       # [OPTIONAL] if not provided, will default to "false"
    userAssignedIdentityID: ${azurerm_kubernetes_cluster.k8s_cluster.identity[0].principal_id}      # [REQUIRED] If you're using a service principal, use the client id to specify which user-assigned managed identity to use. If you're using a user-assigned identity as the VM's managed identity, specify the identity's client id. If the value is empty, it defaults to use the system-assigned identity on the VM
                                                                        #     az ad sp show --id http://contosoServicePrincipal --query appId -o tsv
                                                                        #     the preceding command will return the client ID of your service principal
    keyvaultName: "${var.keyvault_name}"                                # [REQUIRED] the name of the key vault
                                                             #     az keyvault show --name contosoKeyVault5
                                                             #     the preceding command will display the key vault metadata, which includes the subscription ID, resource group name, key vault 
    cloudName: ""                                            # [OPTIONAL for Azure] if not provided, Azure environment will default to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: titi
          objectType: secret
          objectVersion: ""
    resourceGroup: "${var.others_resource_group_name}"                            # [REQUIRED] the resource group name of the key vault
    subscriptionId: "${data.azurerm_client_config.current.subscription_id}"        # [REQUIRED] the subscription ID of the key vault
    tenantId: "${data.azurerm_client_config.current.tenant_id}"              # [REQUIRED] the tenant ID of the key vault
EOF

  aadpodidentity_yaml = <<EOF
apiVersion: aadpodidentity.k8s.io/v1 
kind: AzureIdentity 
metadata: 
  name: "${var.pod_identity}"                # The name of your Azure identity 
spec: 
  type: 0                                     # Set type: 0 for managed service identity 
  resourceID: ${azurerm_user_assigned_identity.identity.id} 
  clientID: ${azurerm_user_assigned_identity.identity.client_id}      # The clientId of the Azure AD identity that you created earlier"

---
apiVersion: aadpodidentity.k8s.io/v1
kind: AzureIdentityBinding
metadata:
    name: "${var.pod_identity}-binding"
spec:
    azureIdentity: "${var.pod_identity}"       # The name of your Azure identity
    selector: poc-aks-selector
EOF

  pod_yaml = <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: poc-aks-test
  labels:
    aadpodidbinding: poc-aks-selector
spec:
  containers:
    - name: nginx-test
      image: nginx
      volumeMounts:
        - name: secrets-store-inline
          mountPath: "/mnt/secrets-store"
          readOnly: true
  volumes:
    - name: secrets-store-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: poc-aks-registry-secret
EOF
}