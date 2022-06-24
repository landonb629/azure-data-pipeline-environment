locals {
  region = "eastus"
  tags = {
      "Owner" = var.email
      "Environment" = "Development"
      "Resources" = "AzureSQL"
  }
  scope = "${data.azurerm_subscription.current.id}/resourceGroups/${var.name}"
}
####################
## resource group ##
####################
resource "azurerm_resource_group" "RG" {
  name = var.name
  location = local.region
  tags = local.tags 
}
#####################
## role assignment ## 
#####################

resource "azurerm_role_assignment" "access-role" {
  count = var.email ? 1 : 0
  scope = local.scope
  role_definition_name = "Owner"
  principal_id = data.azuread_user.user.id
  depends_on = [
    azurerm_resource_group.RG
  ]
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
resource "azurerm_subnet" "cloud-subnet" {
  name = "${var.name}-cloud-subnet"
  resource_group_name = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["${cidrsubnet(var.address_space, 4, 0)}"]
}
resource "azurerm_subnet" "on-premise-subnet" {
  name = "${var.name}-onpremise-subnet"
  resource_group_name = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["${cidrsubnet(var.address_space, 4, 1)}"]
}
############################
## network security group ## 
############################
resource "azurerm_network_security_group" "allow-connection-from-IP" {
  name = "${var.name}-NSG"
  location = local.region
  resource_group_name = azurerm_resource_group.RG.name
}
resource "azurerm_network_security_rule" "source-IP" {
  name = "allow-from-user-source-IP"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = var.source_ip_address
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.RG.name
  network_security_group_name = azurerm_network_security_group.allow-connection-from-IP.name
}

##################
## data factory ##
##################
resource "azurerm_data_factory" "data-factory" {
  name = "${var.name}-data-factory"
  location = local.region
  resource_group_name = azurerm_resource_group.RG.name
  tags = local.tags
}
################
## sql server ## 
################
resource "azurerm_mssql_server" "sql-server" {
  name = "${var.name}-sql-server"
  resource_group_name = azurerm_resource_group.RG.name
  location = local.region
  version = "12.0"
  minimum_tls_version = "1.2"

  azuread_administrator {
    azuread_authentication_only = true
    login_username = var.email
    object_id = data.azuread_user.user.object_id
  }
  tags = local.tags 
}
##################
## sql database ## 
##################
resource "azurerm_mssql_database" "cloud-database" {
  name = "${var.name}-cloud-database"
  server_id = azurerm_mssql_server.sql-server.id
  license_type = "BasePrice"
  max_size_gb = "5"
  sku_name = "S0"
  zone_redundant = false
  geo_backup_enabled = false 



  tags = local.tags
}
resource "azurerm_mssql_firewall_rule" "source_ip" {
  name = "allow-source-ip"
  server_id = azurerm_mssql_server.sql-server.id
  start_ip_address = var.source_ip_address
  end_ip_address = var.source_ip_address
}
#####################################
## self hosted integration runtime ##
#####################################
resource "azurerm_data_factory_integration_runtime_self_hosted" "on-prem-data-source" {
  name = "${var.name}-self-hosted-IR"
  data_factory_id = azurerm_data_factory.data-factory.id
}
#####################
## virtual machine ##
#####################
resource "azurerm_virtual_machine" "on-premise-vm" {
  name = "${var.name}-VM"
  location = local.region
  resource_group_name = azurerm_resource_group.RG.name
  vm_size = "Standard_B2ms"
  network_interface_ids = [azurerm_network_interface.net-interface.id]

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.name}-OS-disk"
    managed_disk_type = "Standard_LRS"
    create_option = "Attach"
  }

  os_profile {
    computer_name = "${var.name}-onPrem"
    admin_username = "win-admin"
    admin_password = var.password
  }
}
resource "azurerm_public_ip" "public-ip" {
  name = "${var.name}-public-ip"
  resource_group_name = azurerm_resource_group.RG.name
  location = local.region
  allocation_method = "Dynamic"
}
resource "azurerm_network_interface" "net-interface" {
  name = "${var.name}-network-interface"
  location = local.region
  resource_group_name = azurerm_resource_group.RG.name
  
  ip_configuration {
    name = "on-premise-ip-config"
    subnet_id = azurerm_subnet.on-premise-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip.name
  }
}