module "hybrid-dev-environment" {
  source = "../../modules/azure-hybrid-data-pipeline"

  name = var.name
  email = var.email
  source_ip_address = var.users-source-ip
  address_space = var.address_space
  
}