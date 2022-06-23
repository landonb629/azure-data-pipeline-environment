data "azuread_user" "user" {
  user_principal_name = var.email
}
data "azurerm_subscription" "current" {
  
}