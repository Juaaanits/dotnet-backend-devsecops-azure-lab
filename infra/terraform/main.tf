locals {
  name = "${var.project_name}-${var.environment}"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${local.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${local.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_storage_account" "this" {
  name                     = replace("st${local.name}", "-", "")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_mssql_server" "this" {
  name                         = "sql-${local.name}"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_database" "this" {
  name      = "SakennyDB"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "Basic"
  tags      = var.tags
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServicesForDemo"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_service_plan" "this" {
  name                = "plan-${local.name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = var.tags
}

resource "azurerm_key_vault" "this" {
  name                       = "kv-${local.name}"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  tags                       = var.tags
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "terraform_key_vault" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "database" {
  name         = "DatabaseConnectionString"
  key_vault_id = azurerm_key_vault.this.id
  value        = "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.this.name};User ID=${var.sql_admin_login};Password=${var.sql_admin_password};Encrypt=True;TrustServerCertificate=False;"
  depends_on   = [azurerm_role_assignment.terraform_key_vault]
}

resource "azurerm_key_vault_secret" "storage" {
  name         = "BlobConnectionString"
  key_vault_id = azurerm_key_vault.this.id
  value        = azurerm_storage_account.this.primary_connection_string
  depends_on   = [azurerm_role_assignment.terraform_key_vault]
}

resource "azurerm_key_vault_secret" "jwt" {
  name         = "JwtSigningKey"
  key_vault_id = azurerm_key_vault.this.id
  value        = var.jwt_key
  depends_on   = [azurerm_role_assignment.terraform_key_vault]
}

resource "azurerm_key_vault_secret" "bootstrap_admin_password" {
  name         = "BootstrapAdminPassword"
  key_vault_id = azurerm_key_vault.this.id
  value        = var.bootstrap_admin_password
  depends_on   = [azurerm_role_assignment.terraform_key_vault]
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-${local.name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_service_plan.this.location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  tags                = var.tags

  identity { type = "SystemAssigned" }

  site_config {
    always_on = true
    application_stack { dotnet_version = "8.0" }
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this.connection_string
    "ConnectionStrings__DefaultConnection"  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database.versionless_id})"
    "AzureBlobStorage__ConnectionString"    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage.versionless_id})"
    "AzureBlobStorage__ContainerName"       = azurerm_storage_container.images.name
    "Jwt__Key"                              = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt.versionless_id})"
    "Jwt__Issuer"                           = "sakenny-azure"
    "Jwt__Audience"                         = "sakenny-client"
    "Jwt__ExpiryMinutes"                    = "60"
    "Jwt__RememberMeExpiryMinutes"          = "10080"
    "Jwt__RefreshTokenExpiryDays"           = "7"
    "Jwt__RememberMeRefreshTokenExpiryDays" = "30"
    "Database__ApplyMigrations"             = "true"
    "BootstrapAdmin__Username"              = var.bootstrap_admin_username
    "BootstrapAdmin__Email"                 = var.bootstrap_admin_email
    "BootstrapAdmin__Password"              = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bootstrap_admin_password.versionless_id})"
  }
}

resource "azurerm_role_assignment" "webapp_key_vault" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}
