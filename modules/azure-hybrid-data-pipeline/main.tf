locals {
  region = "eastus"
}
####################
## resource group ##
####################
resource "azurerm_resource_group" "RG" {
  name = var.name
  location = local.region
}
##########
## vnet ## 
##########
resource "azurerm_virtual_network" "vnet" {
  name = var.name
  location = local.region
  resource_group_name = azurerm_resource_group.RG.name
  address_space = [var.address_space]
}
#############
## subnets ## 
#############
resource "azurerm_subnet" "subnet1" {
  name = "${var.name}-cloud-subnet"
  resource_group_name = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["${cidrsubnet(var.address_space, 4, 0)}"]
}
resource "azurerm_subnet" "subnet2" {
  name = "${var.name}-onpremise-subnet"
  resource_group_name = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["${cidrsubnet(var.address_space, 4, 1)}"]
}