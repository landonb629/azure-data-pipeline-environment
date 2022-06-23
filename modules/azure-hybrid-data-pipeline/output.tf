output "sql-database" {
  value = azurerm_mssql_database.cloud-database.name
}
output "sql-server" {
  value = azurerm_mssql_server.sql-server.fully_qualified_domain_name
}
output "resource-group" {
  value = azurerm_resource_group.RG.name
}
output "primary_auth_key" {
  value = azurerm_data_factory_integration_runtime_self_hosted.on-prem-data-source.primary_authorization_key
}