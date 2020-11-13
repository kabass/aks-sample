
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
         activate the admin user : username (pocaksacr01) and password (xxxxxx) are created and visible on "Access keys" menu
      2) Tag the image for registry: docker tag poc-aks:1.0 pocaksacr01.azurecr.io/pocaksacr01/poc-aks:1.0
      1) push the image into the registry
          - docker login pocaksacr01.azurecr.io
          - sudo docker push pocaksacr01.azurecr.io/pocaksacr01/poc-aks:1.0

