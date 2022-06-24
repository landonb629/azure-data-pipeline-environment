# Project: Azure Hybrid data pipeline development environment

### What is this?

I recently looked into using azure data factory to move, and transform data from on-premise SQL server into Azure SQL database. After that, I wanted to write terraform that would spin up a development environment that simiulates an on-premise SQL server, an Azure SQL database, and Azure data factory.

The virtual machine that is deployed is acting as an on-premise server, in order to utilize this in azure data factory, do the following: 
- install SQL server developer edition
- install azure self hosted integration runtime (after deploying the resources, the auth key will be a terraform output)

### What does this deploy?

The terraform in this repo will deploy the following: 
1. virtual network 
2. two subnets (on-premise, cloud)
3. Azure data factory 
4. resource group
5. virtual machine (windows)
6. Azure SQL server
7. Azure SQL database

### What do you need before you can deploy?

Before using this repo, I would suggest having a basic understanding of the following: 
- Microsoft Azure 
- Terraform 
- Azure SQL

When deploying resources with this repo, you need to have the following:
1. An azure subscription
2. Azure CLI installed, and logged into your subscription
3. Terraform installed on your machine


### What variables should you supply?
- name: This will be the name of the deployment, a good example would be "Mikes-dev-environment"
- email: This is the email of a valid user in your azure tenant, this is used to assign owner permissions to the resource group
- source_ip_address: the public IP address, this address will be added to the firewall, and network security group 
- address_space: the address space that you would like your vnet to have (can be left null)

### How to deploy resources with this repo
1. Clone the repository locally 
```
git clone https://github.com/landonb629/azure-data-pipeline-environment.git
```
2. change to the production/hybrid-data-factory-dev directory
```
cd azure-data-pipeline-environment/production/hybrid-data-factory-dev
```
3. Supply the necessary variables
    - open variables.tf 
    - fill out the variables with your information 
    - save the file
4. terraform init 
```
terraform init
```
5. terraform plan 
``` 
terraform plan 
```
6. check the plan, make sure that you like the outcome 
7. terraform apply 
```
terraform apply -auto-approve
```
8. your resources should be deployed, check the output to see the primary_auth_key for your self hosted integration runtime
