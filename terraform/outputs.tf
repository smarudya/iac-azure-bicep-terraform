output "resource_group_name" {
  description = "Name of the deployed resource group."
  value       = azurerm_resource_group.this.name
}

output "web_app_hostname" {
  description = "Default hostname of the Linux Web App."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "application_insights_name" {
  description = "Name of the Application Insights component."
  value       = azurerm_application_insights.this.name
}
