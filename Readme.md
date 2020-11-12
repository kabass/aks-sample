
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
