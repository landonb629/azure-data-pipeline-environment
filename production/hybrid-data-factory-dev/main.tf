module "landons-dev-environment" {
  source = "../../modules/azure-hybrid-data-pipeline"

  name = var.name
  email = var.email
  source_ip_address = var.landons-ip
}