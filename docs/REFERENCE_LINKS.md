# Reference Links

This file collects official or primary reference links for the technologies and concepts used in this project.

## .NET and ASP.NET Core

| Topic | Link | Why It Matters |
| --- | --- | --- |
| ASP.NET Core authorization introduction | https://learn.microsoft.com/en-us/aspnet/core/security/authorization/introduction | Explains authentication versus authorization and the authorization model. |
| Simple authorization with `[Authorize]` | https://learn.microsoft.com/en-us/aspnet/core/mvc/security/authorization/simple | Explains how `[Authorize]` protects controllers and actions. |
| Role-based authorization | https://learn.microsoft.com/en-us/aspnet/core/mvc/security/authorization/roles | Relevant to Admin, Host, and User role testing. |
| Policy-based authorization | https://learn.microsoft.com/en-us/aspnet/core/security/authorization/policies | Later improvement path when role checks become more complex. |
| ASP.NET Core configuration | https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration | Explains configuration sources such as appsettings, environment variables, and user secrets. |
| Safe storage of app secrets in development | https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets | Relevant to moving JWT, Stripe, Google, and storage secrets out of appsettings. |
| ASP.NET Core integration tests | https://learn.microsoft.com/en-us/aspnet/core/test/integration-tests | Relevant to future automated API and authorization tests. |
| ASP.NET Core health checks | https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks | Background for the lightweight `/health` endpoint and future dependency-aware checks. |

## GitHub Actions and CI/CD

| Topic | Link | Why It Matters |
| --- | --- | --- |
| GitHub Actions workflows | https://docs.github.com/en/actions/concepts/workflows-and-actions/workflows | Explains what workflows are and where `.github/workflows` files live. |
| Workflow syntax | https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax | Main reference for writing workflow YAML. |
| GitHub Actions jobs | https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-jobs | Explains jobs, runners, and matrices. |
| `GITHUB_TOKEN` security | https://docs.github.com/en/actions/concepts/security/github_token | Relevant to least-privilege workflow permissions. |
| `actions/checkout` | https://github.com/actions/checkout | Official action for checking out repository code. |
| `actions/setup-dotnet` | https://github.com/actions/setup-dotnet | Official action for installing/selecting the .NET SDK in CI. |
| .NET test validation workflow | https://learn.microsoft.com/en-us/dotnet/devops/dotnet-test-github-action | Microsoft guide for .NET build/test workflows in GitHub Actions. |

## Dependency and Supply Chain Security

| Topic | Link | Why It Matters |
| --- | --- | --- |
| Dependabot options reference | https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference | Main reference for `.github/dependabot.yml`. |
| GitHub secret scanning | https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning | Explains secret detection and why secrets should not be committed. |
| Gitleaks | https://github.com/gitleaks/gitleaks | Primary project for local/CI secret scanning. |

## Static and Container Security Scanning

| Topic | Link | Why It Matters |
| --- | --- | --- |
| CodeQL code scanning | https://docs.github.com/en/code-security/concepts/code-scanning/codeql/codeql-code-scanning | GitHub-native SAST for detecting vulnerabilities and coding errors. |
| CodeQL reference | https://docs.github.com/en/code-security/reference/code-scanning/codeql | Reference for CodeQL behavior and build options. |
| CodeQL C# queries | https://codeql.github.com/codeql-query-help/csharp/ | Shows the kinds of C# issues CodeQL can detect. |
| Trivy action | https://github.com/aquasecurity/trivy-action | Official GitHub Action for filesystem, dependency, IaC, and container scans. |
| Trivy CI/CD docs | https://trivy.dev/docs/latest/ecosystem/cicd/ | Explains how Trivy fits into pipelines. |

## API Testing and QA Automation

| Topic | Link | Why It Matters |
| --- | --- | --- |
| Newman CLI | https://learning.postman.com/docs/reference/newman-cli/command-line-integration-with-newman | Runs Postman collections from the command line and CI. |
| Install and run Newman | https://learning.postman.com/docs/reference/newman-cli/installing-running-newman | Setup and execution reference for collection runs. |
| ASP.NET Core integration tests | https://learn.microsoft.com/en-us/aspnet/core/test/integration-tests | Best future path for automated backend regression tests. |
| `dotnet test` | https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-test | Runs the xUnit regression project locally and in CI. |

## Dynamic Security Testing

| Topic | Link | Why It Matters |
| --- | --- | --- |
| ZAP Docker user guide | https://www.zaproxy.org/docs/docker/about/ | Explains ZAP baseline, full, and API scans through Docker. |
| ZAP baseline GitHub Action | https://github.com/zaproxy/action-baseline | GitHub Action for passive baseline web security scanning. |
| OWASP DevSecOps DAST guideline | https://github.com/OWASP/DevSecOpsGuideline/blob/master/current-version/2-Process/2-4-Test/2-4-2-Dynamic-Application-Security-Testing.md | Useful conceptual reference for DAST in CI/CD. |

## Observability and SQL Server Monitoring

| Topic | Link | Why It Matters |
| --- | --- | --- |
| Grafana Microsoft SQL Server datasource | https://grafana.com/docs/grafana/latest/datasources/mssql/configure/ | Main reference for connecting Grafana to SQL Server. |
| Grafana provisioning | https://grafana.com/tutorials/provision-dashboards-and-data-sources/ | Explains file-based datasource and dashboard provisioning used by this repo. |
| Grafana dashboard JSON model | https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/ | Useful when exporting, reviewing, and versioning dashboard JSON. |
| SQL Server fixed TCP port | https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/configure-a-server-to-listen-on-a-specific-tcp-port | Required when Dockerized Grafana connects to local SQL Server on port 1433. |
| Docker Desktop host networking | https://docs.docker.com/desktop/features/networking/networking-how-tos/ | Explains `host.docker.internal`, which Grafana uses to reach SQL Server on Windows. |
| SQL Server server-level roles | https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/server-level-roles | Helps avoid over-granting sysadmin when creating monitoring users. |
| GRANT system object permissions | https://learn.microsoft.com/en-us/sql/t-sql/statements/grant-system-object-permissions-transact-sql | Reference for scoped permissions needed by monitoring queries. |
| Microsoft SQL Server with Grafana dashboard source | https://github.com/czantoine/microsoft-sql-server-with-grafana | MIT-licensed dashboard imported and adapted for this Sakenny observability lab. |

## Docker and Containers

| Topic | Link | Why It Matters |
| --- | --- | --- |
| Docker .NET guide | https://docs.docker.com/guides/dotnet/ | Practical Docker guide for .NET applications. |
| Containerize a .NET app | https://learn.microsoft.com/en-us/dotnet/core/docker/build-container | Microsoft reference for Dockerfile-based .NET containerization. |
| Containerize with `dotnet publish` | https://learn.microsoft.com/en-us/dotnet/core/containers/sdk-publish | Alternative .NET SDK container publishing flow. |
| Docker Compose | https://docs.docker.com/compose/ | Defines and operates the local SQL Server, Azurite, API, and Grafana stack. |
| Azurite connection strings | https://learn.microsoft.com/en-us/azure/storage/common/storage-connect-azurite | Documents local Azure Storage emulator endpoints and credentials. |

## Azure and Cloud Engineering

| Topic | Link | Why It Matters |
| --- | --- | --- |
| Deploy ASP.NET Core and Azure SQL to App Service | https://learn.microsoft.com/en-us/azure/app-service/tutorial-dotnetcore-sqldb-app | Closest Azure deployment pattern for this backend. |
| Deploy ASP.NET Core apps to Azure App Service | https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/azure-apps/ | General ASP.NET Core App Service deployment reference. |
| Azure Key Vault configuration provider | https://learn.microsoft.com/en-us/aspnet/core/security/key-vault-configuration | Production path for secrets and configuration hardening. |
| Terraform on Azure | https://learn.microsoft.com/en-us/azure/developer/terraform/ | Microsoft landing page for Terraform on Azure. |
| AzureRM Terraform provider | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs | Official provider reference for provisioning Azure resources with Terraform. |
| Terraform GitHub Actions automation | https://developer.hashicorp.com/terraform/tutorials/automation/github-actions | How Terraform can later run from GitHub Actions. |
| Azure OIDC from GitHub | https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect | Passwordless GitHub Actions authentication used by the manual deployment workflow. |
| App Service Key Vault references | https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references | Allows the managed Web App identity to resolve runtime secrets without plaintext settings. |
| Terraform sensitive data | https://developer.hashicorp.com/terraform/language/manage-sensitive-data | Explains sensitive variables, state exposure, and secret-handling limits. |

## SQL Server Performance and Database Reliability

| Topic | Link | Why It Matters |
| --- | --- | --- |
| SQL Server Query Store | https://learn.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store | Future baseline and query regression analysis for property filtering and dashboard queries. |

## Performance and Reliability Testing

| Topic | Link | Why It Matters |
| --- | --- | --- |
| Grafana k6 docs | https://grafana.com/docs/k6/latest/ | Main k6 documentation. |
| k6 HTTP requests | https://grafana.com/docs/k6/latest/using-k6/http-requests/ | Relevant to load testing backend endpoints. |
| k6 API load testing guide | https://grafana.com/docs/k6/latest/testing-guides/api-load-testing/ | Explains smoke, load, stress, spike, breakpoint, and soak testing. |

## AWS Cloud Concepts

These are useful while reviewing for AWS Certified Cloud Practitioner. They also map to DevSecOps/cloud thinking even if this project later deploys first to Azure.

| Topic | Link | Why It Matters |
| --- | --- | --- |
| AWS Shared Responsibility Model | https://aws.amazon.com/compliance/shared-responsibility-model/ | Core cloud security concept: provider secures the cloud, customer secures what they put in it. |
| AWS Well-Architected Framework | https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html | Core cloud architecture pillars: operational excellence, security, reliability, performance efficiency, cost optimization, and sustainability. |
| AWS IAM best practices | https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html | Relevant to least privilege, temporary credentials, MFA, and access review. |
| AWS Cloud Practitioner training | https://aws.amazon.com/training/learn-about/cloud-practitioner/ | Official AWS starting point for Cloud Practitioner learning. |

