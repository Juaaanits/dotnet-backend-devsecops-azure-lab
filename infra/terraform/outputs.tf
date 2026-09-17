output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "key_vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}
