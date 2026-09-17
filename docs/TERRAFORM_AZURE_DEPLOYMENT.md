# Terraform and Azure Deployment Guide

This guide covers the Azure infrastructure defined in `infra/terraform` and the manual GitHub Actions deployment workflow. Infrastructure validation is complete; provisioning is intentionally not claimed until an Azure subscription, approved budget, credentials, and a reviewed plan are available.

## Architecture

```text
GitHub Actions (OIDC)
        |
        v
Azure Linux Web App ---- managed identity ---- Azure Key Vault
        |                                      | database/JWT/admin secrets
        +---- Azure SQL Database
        +---- Azure Blob Storage
        +---- Application Insights ---- Log Analytics
```

Terraform defines the resource group, Log Analytics workspace, Application Insights, storage account and private image container, Azure SQL server and Basic database, Linux B1 App Service plan, Linux Web App, Key Vault, secrets, and RBAC assignments.

## Important Design Decisions

- Secrets are Terraform variables marked sensitive and are stored in Key Vault.
- The Web App reads Key Vault references through managed identity.
- The application exposes `/health` for App Service health checks.
- Database migrations and first-Admin bootstrap are configuration-driven.
- The SQL `0.0.0.0` Azure-services firewall rule is acceptable only for this demo phase. Production should use private networking and a reviewed egress path.
- Terraform state can contain sensitive values. Use an encrypted remote backend before team or production use.

## Prerequisites

Install Terraform, Azure CLI, and .NET 8. Confirm an Azure subscription and review expected charges for App Service, Azure SQL, Log Analytics, Application Insights, Storage, and Key Vault.

```powershell
az login
az account show
terraform -version
```

## Validate Without Provisioning

```powershell
cd .\infra\terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

These commands validate syntax and provider configuration. They do not prove permissions, quotas, name availability, cost, or runtime behavior.

## Supply Sensitive Variables

Use environment variables for a local plan. Do not add secrets to `terraform.tfvars` or commit them.

```powershell
$env:TF_VAR_sql_admin_password = '<strong-unique-password>'
$env:TF_VAR_jwt_key = '<long-random-signing-key>'
$env:TF_VAR_bootstrap_admin_password = '<strong-initial-admin-password>'
```

Copy only nonsensitive values if customization is required:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

The local `.gitignore` excludes `terraform.tfvars`, state files, and `.terraform/`.

## Review a Plan

```powershell
terraform init
terraform plan -out sakenny.tfplan
terraform show sakenny.tfplan
```

Review resource names, region, SKUs, tags, public network exposure, RBAC, and monthly cost. The plan file can contain sensitive material and must not be committed.

## Apply and Validate

Only after approval:

```powershell
terraform apply sakenny.tfplan
terraform output
```

Then configure GitHub repository secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`, plus repository variable `AZURE_WEBAPP_NAME`. Configure an Azure federated identity for the GitHub repository and `development` environment. Run **Azure Web App deployment** manually.

Validate:

```text
1. Deployment workflow passes.
2. https://<app>.azurewebsites.net/health returns 200.
3. Bootstrap Admin login works once without exposing its password.
4. Public property endpoints respond.
5. Application Insights receives requests and failures.
6. Key Vault references resolve without plaintext app settings.
7. Azure SQL and Storage access follow the intended boundaries.
```

Rotate or remove the bootstrap password after establishing a managed administrative process.

## Destroy a Temporary Lab

Export any required evidence first, then run:

```powershell
terraform plan -destroy
terraform destroy
```

Confirm resources are removed in Azure Cost Management and the portal. Key Vault soft deletion can preserve a recoverable vault for the configured retention period.

## Production Hardening Backlog

```text
Remote Azure Storage backend with state locking controls
Separate dev/staging/prod state and variables
Private endpoints for SQL, Storage, and Key Vault
Network restrictions on the Web App
Azure SQL Entra authentication or dedicated least-privilege login
Diagnostic settings and actionable alerts
Backup and restore tests
WAF/Application Gateway only when threat model and budget justify it
Approval-protected deployment environments
Post-deployment Newman and rollback procedure
```

## Official References

- [Terraform on Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/)
- [Azure Login with OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
- [Key Vault references for App Service](https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references)
- [App Service deployment action](https://github.com/Azure/webapps-deploy)
- [Terraform sensitive data](https://developer.hashicorp.com/terraform/language/manage-sensitive-data)
