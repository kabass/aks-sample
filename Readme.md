
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
      2) docker build -t rodart/poc-aks:1.0 spring-boot-data-jpa-mysql/docker
   3) Push