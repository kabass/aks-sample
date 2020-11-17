
https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks
1) create sp
az ad sp create-for-rbac -n "poc_aks_sp"

"tenant": "93ff53b8-fc5d-4538-a2f8-4e78dbdd9039"

2) backend creation
a- creation of backend resource
cd backend
terraform fmt
terraform validate
terraform apply
b- specification of backend on backend.tf file

3) apply config
terraform fmt
terraform validate
terraform apply

4) Connect to kubernetes cluster
az aks get-credentials --name poc_aks_cluster --resource-group poc_aks_rg

4) Create registry in azure


5) Create sample java/maven project
   the project use mysql as datasource

6) create kubernetes manifest file
   1) create database tier
      1) create azure file storage class
      2) create pvc
      3) create volume
      4) create secret for database password
      5) create deployment for database
      6) create service for database
   2) create front deployment
      0) create registry secret : kubectl create secret docker-registry regcred --docker-server=pocaksacr01.azurecr.io --docker-username=pocaksacr01 --docker-password=xxxx --docker-email=toto@gmail.com
      1) create config map fro environment
      2) create secret for database password
      3) create pvc
      4) create volume
      5) create deployment for application
      6) create service for application
7) CI / CD
   1) Build project using : 
      1) cd spring-boot-data-jpa-mysql
      2) mvn clean package
   2) Build image  
      1) cd spring-boot-data-jpa-mysql
      2) sudo docker build -t poc-aks:1.0 .
   3) Push
      1) Create a registry account on azure (ACR) : pocaksacr01
         activate the "admin user" : username (pocaksacr01) and password (xxxxxx) are created and visible on "Access keys" menu
      2) Tag the image for registry: docker tag poc-aks:1.0 pocaksacr01.azurecr.io/pocaksacr01/poc-aks:1.0
      1) push the image into the registry
          - docker login pocaksacr01.azurecr.io
          - sudo docker push pocaksacr01.azurecr.io/pocaksacr01/poc-aks:1.0

8) Helm
  1) install Helm
    https://helm.sh/docs/intro/install/
  2) ensure the congig is correct 
    kubectl cluster-info
  3)Creating a Chart
    helm create poc-aks-helm
  4)- Creating Template
    we have to edit manually the template files
    - Providing Values
    edit value files
  5)- runs a battery of tests to ensure that the chart is well-formed
    helm lint ./poc-aks-helm
    - render the template locally, without a Tiller Server, for quick feedback
    helm template ./poc-aks-helm 
  6)installation/release
    helm install ./poc-aks-helm --generate-name
    or
    helm upgrade poc-aks-helm ./poc-aks-helm
  7)see which charts are installed
    helm ls --all
  8)delete all the release
    helm uninstall poc-aks-helm

  9)installs the secrets-store-csi-driver and the azure keyvault provider for the driver
    https://docs.microsoft.com/en-us/azure/key-vault/general/key-vault-integrate-kubernetes 
    a- use managed identities ==> Helm via Terraform
       deploy AKS with managed identity enabled
       https://github.com/terraform-providers/terraform-provider-azurerm/issues/4506

    b- Install the Secrets Store CSI driver ==> Helm Terraform ?
       helm repo add csi-secrets-store-provider-azure https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts
       helm install csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --generate-name
    c- Create your own SecretProviderClass object ==> Helm
       https://github.com/Azure/secrets-store-csi-driver-provider-azure#create-a-new-azure-key-vault-resource-or-use-an-existing-one
    d- use managed identities on AKS pod 
       i) To create, list, or read a user-assigned managed identity, your AKS cluster needs to be assigned the Managed Identity Operator role. ==> Terraform
          clientId=b4aba041-4980-4140-9125-93705b8f21aa
          SUBID=b257a86c-9b05-45ac-b405-69a297df5ee2
          RESOURCE_GROUP=poc_aks_rg
          NODE_RESOURCE_GROUP=MC_poc_aks_rg_poc_aks_cluster_eastus
          az role assignment create --role "Managed Identity Operator" --assignee $clientId --scope /subscriptions/$SUBID/resourcegroups/$RESOURCE_GROUP
          az role assignment create --role "Managed Identity Operator" --assignee $clientId --scope /subscriptions/$SUBID/resourcegroups/$NODE_RESOURCE_GROUP
          az role assignment create --role "Virtual Machine Contributor" --assignee $clientId --scope /subscriptions/$SUBID/resourcegroups/$NODE_RESOURCE_GROUP
       ii) Install the Azure Active Directory (Azure AD) identity into AKS ==> Helm via Terraform ?
          helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
          helm install pod-identity aad-pod-identity/aad-pod-identity
       iii) Create an Azure AD identity. In the output, copy the clientId and principalId for later use ==> terraform ?
          az identity create -g $resourceGroupName -n $identityName
       iv) Assign the Reader role to the Azure AD identity  ==> terraform
          az role assignment create --role "Reader" --assignee $principalId --scope /subscriptions/$SUBID/resourceGroups/contosoResourceGroup/providers/Microsoft.KeyVault/vaults/contosoKeyVault5
          az keyvault set-policy -n contosoKeyVault5 --secret-permissions get --spn $clientId
          az keyvault set-policy -n contosoKeyVault5 --key-permissions get --spn $clientId
    e- edit your pod with mounted secrets from your key vault.  ==> Helm
       i) create an AzureIdentity in your cluster that references the identity that you created earlier
          apiVersion: aadpodidentity.k8s.io/v1
          kind: AzureIdentity
          metadata:
              name: "azureIdentityName"               # The name of your Azure identity
          spec:
              type: 0                                 # Set type: 0 for managed service identity
              resourceID: /subscriptions/<SUBID>/resourcegroups/<RESOURCEGROUP>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<AZUREIDENTITYNAME>
              clientID: "managedIdentityClientId"     # The clientId of the Azure AD identity that you created earlier

       ii) create an AzureIdentityBinding that references the AzureIdentity you created
          apiVersion: aadpodidentity.k8s.io/v1
          kind: AzureIdentityBinding
          metadata:
              name: azure-pod-identity-binding
          spec:
              azureIdentity: "azureIdentityName"      # The name of your Azure identity
              selector: azure-pod-identity-binding-selector

