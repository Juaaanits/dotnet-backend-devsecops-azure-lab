# Sakenny Backend QA, DevSecOps, and Cloud Engineering Lab

This repository is my personal engineering extension of the MIT-licensed Sakenny backend project. I cloned the original project to practice the kind of work expected from an Automation QA, DevSecOps, and Cloud Engineer: reproducing an existing backend locally, validating its behavior, finding defects, documenting the workflow, planning automated tests, improving security posture, and preparing it for cloud deployment.

The original Sakenny backend is a .NET 8 property rental API with SQL Server, ASP.NET Identity, JWT authentication, Stripe integration, Google auth support, and Azure Blob Storage support. My work focuses on the backend engineering workflow around it: setup, testing, bug discovery, DevSecOps hardening, SQL Server validation, and Azure readiness.

## Project Status

Current phase: local validation, automated QA, CI/security gates, container orchestration, SQL observability, and validated Azure Terraform baseline completed. Azure resources have not been provisioned.

Validated on 2026-09-05:

```text
.NET backend runs locally
SQL Server connection works
EF Core migrations applied
ASP.NET Identity roles created
JWT login works
Admin authorization works
Host authorization works
Azurite image upload works
Property creation works
Property approval works
Property-service relationship works
Public property listing/filter/detail works
Host-owned property endpoints work
Admin dashboard endpoints work
Services API creates Name + Icon through the API
Type and Services mutation endpoints enforce Admin-only access
```

Observability validated on 2026-09-13:

```text
Grafana runs locally through Docker Compose
Grafana connects to SQL Server through host.docker.internal:1433
SakennyDB dashboard loads SQL Server operational panels
grafana_reader uses scoped monitoring permissions instead of sysadmin
Dashboard evidence screenshots are stored under docs/evidence
```

CI and dependency monitoring evidence:

```text
GitHub Actions .NET restore/build workflow passed
Dependabot created automated update PRs for GitHub Actions
Dependabot created automated update PRs for NuGet packages
Dependabot PRs showed 2/2 passing checks before review
Initial Dependabot PR queue was cleared to 0 open pull requests
CodeQL C# scanning was added and merged after repository code scanning was enabled
SQL Server monitoring dashboard runs locally through Grafana and Docker
xUnit authorization/storage regression tests are part of the solution
Postman/Newman smoke automation covers public, User, Host, and Admin behavior
Docker Compose defines SQL Server, Azurite, API, SQL initialization, and Grafana
Trivy container scanning and Terraform validation workflows are defined
Terraform validation passes for the Azure App Service, SQL, Storage, Key Vault, and monitoring baseline
```

Evidence screenshot:

```text
docs/evidence/github-pr-queue-cleared.png
docs/evidence/grafana-sql-dashboard-overview.png
docs/evidence/grafana-sql-dashboard-security-monitoring.png
docs/evidence/grafana-sql-dashboard-index-health.png
```

## My Engineering Focus

This project is being developed as a practical portfolio lab for:

```text
Automation QA
API test planning
Postman/Newman automation
ASP.NET Core/xUnit regression testing
SQL Server validation and performance analysis
DevSecOps quality gates
Secret management
Container and dependency scanning
Azure deployment readiness
Terraform infrastructure validation and Azure deployment readiness
Monitoring and operational visibility
```

## Documentation

The project documentation is organized as evidence of the validation and improvement process:

| Document | Purpose |
| --- | --- |
| [Local Setup and Validation Report](docs/LOCAL_SETUP_AND_VALIDATION.md) | Reproducible local setup, SQL Server/Azurite requirements, and what was validated. |
| [API Test Runbook](docs/API_TEST_RUNBOOK.md) | Manual Swagger/Postman workflow that can become an automated test suite. |
| [SQL Server Test Notes](docs/SQL_SERVER_TEST_NOTES.md) | Database checks, validation queries, and future performance baseline plan. |
| [Known Issues and Fix Plan](docs/KNOWN_ISSUES_AND_FIX_PLAN.md) | Bugs and improvement items found during testing, with fix and validation criteria. |
| [DevOps and DevSecOps Checklist](docs/DEVOPS_DEVSECOPS_CHECKLIST.md) | Permanent checklist for CI, Dependabot, security gates, evidence, and next DevSecOps tasks. |
| [SQL Server Observability With Grafana](docs/OBSERVABILITY_SQL_SERVER_GRAFANA.md) | Local Grafana + SQL Server monitoring setup, permissions, dashboard evidence, and troubleshooting notes. |
| [QA, DevSecOps, and Cloud Roadmap](docs/QA_DEVSECOPS_CLOUD_ROADMAP.md) | Roadmap for automated QA, security gates, CI/CD, SQL tuning, Terraform, and Azure. |
| [Technical Case Study and Onboarding Handbook](docs/SAKENNY_TECHNICAL_CASE_STUDY.md) | Canonical portfolio narrative and compilation guide for the full 20-30 page handbook. |
| [Automated QA and Container Runbook](docs/AUTOMATED_QA_AND_CONTAINER_RUNBOOK.md) | xUnit, Postman/Newman, Docker Compose, CI artifacts, and troubleshooting. |
| [Terraform and Azure Deployment Guide](docs/TERRAFORM_AZURE_DEPLOYMENT.md) | Validated infrastructure, OIDC deployment steps, costs, security boundaries, and production backlog. |
| [Final Project Status](docs/FINAL_PROJECT_STATUS.md) | Evidence matrix separating implemented, verified, and external credential-dependent work. |
| [Portfolio Case Study Draft](docs/PORTFOLIO_CASE_STUDY_DRAFT.md) | Short recruiter/interview-facing summary retained for quick review. |
| [Reference Links](docs/REFERENCE_LINKS.md) | Categorized official references for .NET, QA, DevSecOps, CI/CD, Docker, Azure, Terraform, SQL Server, k6, and AWS cloud concepts. |

## Tech Stack

Application stack inherited from the original backend:

```text
.NET 8
ASP.NET Core Web API
Entity Framework Core
SQL Server
ASP.NET Identity
JWT Bearer authentication
AutoMapper
Swagger/OpenAPI
Azure Blob Storage / Azurite
Stripe SDK
Google auth library
```

Engineering workflow being added around it:

```text
Manual API validation
Postman collection and Newman JUnit automation
xUnit regression tests
Docker/Docker Compose local stack
GitHub Actions CI build gate
Dependabot dependency monitoring
CodeQL SAST scanning
Grafana SQL Server observability dashboard
SAST, secret, and container scanning
Validated Terraform and manual OIDC Azure deployment workflow
SQL Server performance baseline plan
```

## Local Run Summary

The fastest reproducible path is the root container stack:

```powershell
Copy-Item .env.example .env
# Replace every placeholder value in the ignored .env file.
.\scripts\dev-up.ps1
.\scripts\test-smoke.ps1
```

This exposes the API at `http://localhost:5111`, Grafana at `http://localhost:3000`, and container SQL Server at `localhost,14330`. Detailed instructions are in [docs/AUTOMATED_QA_AND_CONTAINER_RUNBOOK.md](docs/AUTOMATED_QA_AND_CONTAINER_RUNBOOK.md).

The original Windows-hosted setup remains available below.

Prerequisites:

```text
.NET 8 SDK
SQL Server Express or Developer Edition
SQL Server instance available as .\SQLEXPRESS
Docker for Azurite, or another local Azurite installation
```

Restore and build:

```powershell
dotnet restore .\sakenny.sln
dotnet build .\sakenny.sln
```

Apply migrations:

```powershell
dotnet ef database update --project .\sakenny\sakenny.csproj --startup-project .\sakenny\sakenny.csproj
```

Start Azurite:

```powershell
docker run --rm -it `
  -p 10000:10000 `
  -p 10001:10001 `
  -p 10002:10002 `
  --name sakenny-azurite `
  mcr.microsoft.com/azure-storage/azurite
```

Run the API:

```powershell
dotnet run --project .\sakenny\sakenny.csproj --launch-profile https
```

Open Swagger:

```text
https://localhost:7279/swagger/index.html
```

Detailed setup and validation steps are in [docs/LOCAL_SETUP_AND_VALIDATION.md](docs/LOCAL_SETUP_AND_VALIDATION.md).

Build the combined portfolio book:

```powershell
.\scripts\build-portfolio.ps1
# With Pandoc and a PDF engine installed:
.\scripts\build-portfolio.ps1 -Pdf
```

Generated Markdown, HTML, and PDF files are written to ignored `artifacts/portfolio/` so the maintained source remains the documentation under `docs/`.

## Manual Validation Completed

The following end-to-end API flow has been tested locally:

```text
Register user
Login user
Use a configured bootstrap Admin or register another Admin while authenticated as Admin
Login admin
Convert user to Host
Create property type
Create services through API after fixing the Icon contract
Create property as Host
Upload images to Azurite
Approve property as Admin
List public properties
Filter public properties
View property details
View host-owned properties
Call admin dashboard endpoints
```

Sample validated database evidence:

```text
Property 2 -> Service 5
Property 2 -> Service 6
Property 2 -> Service 7
```

## Issues Found During Validation

The first testing pass found real improvement opportunities:

```text
Authentication middleware ordering needed app.UseAuthentication() - fixed and validated
POST /api/Services failed because Icon was required but missing from AddServiceDTO - fixed and validated
Type and Services mutation endpoints needed Admin-only protection - fixed and validated
Duplicate Azure.Storage.Blobs package reference was cleaned after Dependabot conflict resolution
CodeQL C# scanning was added after enabling GitHub code scanning
Grafana SQL Server monitoring was added with a dedicated read-only database login
BlobService constructor storage coupling was removed and regression-tested
Anonymous Admin registration was closed; first-Admin creation now requires explicit bootstrap configuration
Some routes use absolute paths and are inconsistent
Secrets should move out of appsettings.json
EF model warnings need cleanup
Dashboard nullable warnings need cleanup; CI passes but reports nullable warnings
```

Full issue details are tracked in [docs/KNOWN_ISSUES_AND_FIX_PLAN.md](docs/KNOWN_ISSUES_AND_FIX_PLAN.md).

## Roadmap

Remaining engineering milestones:

```text
1. Retain the first successful xUnit, Newman, Trivy, and Terraform artifacts from GitHub Actions.
2. Add database-backed integration tests for high-risk business flows.
3. Create a SQL Server performance baseline using API load and Grafana evidence.
4. Resolve nullable, EF relationship, and decimal-precision warnings with targeted tests.
5. Standardize API routes with a backward-compatibility plan.
6. Prevent duplicate lookup values where the domain requires uniqueness.
7. Review an Azure Terraform plan, expected cost, and security exposure.
8. Provision a temporary Azure environment only after approval, then run deployment smoke tests.
9. Add remote Terraform state, private networking, alerts, and backup/restore evidence.
```

The full roadmap is in [docs/QA_DEVSECOPS_CLOUD_ROADMAP.md](docs/QA_DEVSECOPS_CLOUD_ROADMAP.md).

## Original Project Attribution

This repository is based on the open-source Sakenny backend project, originally presented as a graduation project by the ITI Alexandria Full Stack Development Track team. The original project is licensed under the MIT License, and this repository keeps that license and attribution intact.

Original team credited in the source README:

| Name | GitHub |
| --- | --- |
| Mohab Wafaie | [@MohabWafaie](https://github.com/MohabWafaie) |
| Ahmed Waleed | [@Ahmedabdeen15](https://github.com/Ahmedabdeen15) |
| Nancy EL Sherbiny | [@NancELSherbiny](https://github.com/NancELSherbiny) |
| Marwan Fawzy Shahat Mahmoud | [@ArabianHindi](https://github.com/ArabianHindi) |
| Rodina Elfeky | [@RodinaElfeky](https://github.com/RodinaElfeky) |
| Ahmed Aseel | [@Ahmed-Aseel](https://github.com/Ahmed-Aseel) |

Frontend repository referenced by the original README:

```text
https://github.com/CozyQuest/front-end-.git
```

## License

This project remains under the MIT License. See [LICENSE](LICENSE).

My additions in this repository are focused on documentation, validation workflow, QA/DevSecOps planning, and future cloud engineering improvements around the original backend.
