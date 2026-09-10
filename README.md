# Sakenny Backend QA, DevSecOps, and Cloud Engineering Lab

This repository is my personal engineering extension of the MIT-licensed Sakenny backend project. I cloned the original project to practice the kind of work expected from an Automation QA, DevSecOps, and Cloud Engineer: reproducing an existing backend locally, validating its behavior, finding defects, documenting the workflow, planning automated tests, improving security posture, and preparing it for cloud deployment.

The original Sakenny backend is a .NET 8 property rental API with SQL Server, ASP.NET Identity, JWT authentication, Stripe integration, Google auth support, and Azure Blob Storage support. My work focuses on the backend engineering workflow around it: setup, testing, bug discovery, DevSecOps hardening, SQL Server validation, and Azure readiness.

## Project Status

Current phase: local backend validation, first bug-fix validation, and first CI/dependency monitoring gate completed.

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

CI and dependency monitoring evidence:

```text
GitHub Actions .NET restore/build workflow passed
Dependabot created automated update PRs for GitHub Actions
Dependabot created automated update PRs for NuGet packages
Dependabot PRs showed 2/2 passing checks before review
```

## My Engineering Focus

This project is being developed as a practical portfolio lab for:

```text
Automation QA
API test planning
Postman/Newman automation
ASP.NET Core integration testing
SQL Server validation and performance analysis
DevSecOps quality gates
Secret management
Container and dependency scanning
Azure deployment readiness
Terraform infrastructure planning
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
| [One-Hour DevOps and DevSecOps Plan](docs/ONE_HOUR_DEVOPS_DEVSECOPS_PLAN.md) | Short, focused plan for adding a CI quality gate and dependency monitoring. |
| [QA, DevSecOps, and Cloud Roadmap](docs/QA_DEVSECOPS_CLOUD_ROADMAP.md) | Roadmap for automated QA, security gates, CI/CD, SQL tuning, Terraform, and Azure. |
| [Portfolio Case Study Draft](docs/PORTFOLIO_CASE_STUDY_DRAFT.md) | Recruiter/interview-facing summary of the project direction and evidence. |
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
Postman collection planning
Newman test automation plan
xUnit integration testing plan
Docker/Docker Compose plan
GitHub Actions CI build gate
Dependabot dependency monitoring
SAST/secret/container scanning plan
Terraform and Azure deployment plan
SQL Server performance baseline plan
```

## Local Run Summary

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

## Manual Validation Completed

The following end-to-end API flow has been tested locally:

```text
Register user
Login user
Register admin
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
BlobService connects to Azurite during service construction
Some routes use absolute paths and are inconsistent
Secrets should move out of appsettings.json
EF model warnings need cleanup
Dashboard nullable warnings need cleanup; CI passes but reports nullable warnings
```

Full issue details are tracked in [docs/KNOWN_ISSUES_AND_FIX_PLAN.md](docs/KNOWN_ISSUES_AND_FIX_PLAN.md).

## Roadmap

Next engineering milestones:

```text
1. Review and merge safe Dependabot PRs after CI passes.
2. Add CodeQL SAST scanning.
3. Decouple blob storage initialization from unrelated requests.
4. Move sensitive configuration to user-secrets, environment variables, and later Azure Key Vault.
5. Create a Postman collection for the validated API flow.
6. Add automated integration tests.
7. Add Docker Compose for SQL Server and Azurite dependencies.
8. Add secret scanning and container scanning.
9. Create a SQL Server performance baseline.
10. Prevent duplicate lookup values where the domain requires uniqueness.
11. Deploy to Azure with Terraform and add monitoring.
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
