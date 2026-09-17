# Sakenny Backend QA, DevSecOps, and Cloud Engineering Lab

## Technical Case Study and Onboarding Handbook

**Maintainer:** Juaaanits

**Repository:** https://github.com/Juaaanits/sakenny-backend-qa-devsecops-cloud-lab

**Platform:** ASP.NET Core 8, EF Core, SQL Server, Docker, GitHub Actions

**Version:** 1.0, September 2026

**Status:** Portfolio-ready living document

> This handbook documents engineering improvements made around an existing MIT-licensed backend. It is suitable for a portfolio PDF, repository attachment, technical interview, and newcomer onboarding.

---

## Document Map

This is the master narrative for a 20 to 30-page PDF. The detailed guides listed in the final appendix are its supporting chapters and should be included in the stated compilation order when producing the full book.

1. Executive Summary
2. Project Overview and Objectives
3. Architecture and Stack
4. Implementation and Engineering Challenges
5. CI, DevSecOps, and Observability
6. Impact and Results
7. Newcomer Setup Guide
8. Troubleshooting and Operations
9. Limitations and Roadmap
10. Portfolio Positioning
11. PDF Compilation Plan

---

# 1. Executive Summary

Sakenny is a property-rental backend using ASP.NET Core, Entity Framework Core, SQL Server, ASP.NET Identity, JWT authentication, Azure Blob-compatible storage, Stripe, and Google authentication support. The source already contained substantial application functionality, but it lacked a complete workflow for repeatable setup, quality validation, security scanning, observability, and cloud delivery.

This project treats the repository as an inherited system rather than claiming a rewrite. The work began by reproducing the environment, understanding its data and authorization model, and testing the real API and database. Defects were recorded with symptoms, root causes, fixes, evidence, and regression criteria.

Delivered improvements include:

- Validated .NET 8 and SQL Server local environment.
- Azurite-based local blob storage.
- API and SQL validation runbooks.
- Correct authentication middleware ordering.
- Corrected Services API contract for required icon data.
- Admin-only Type and Service mutations.
- GitHub Actions build quality gate.
- Dependabot for NuGet and GitHub Actions.
- CodeQL static application security testing.
- Gitleaks secret scanning.
- Provisioned Grafana SQL Server dashboard.
- Dedicated least-privilege SQL monitoring login.
- xUnit authorization and storage-constructor regression tests.
- A 16-request Postman/Newman role and API smoke suite.
- Reproducible SQL Server, Azurite, API, and Grafana Compose stack.
- Trivy container scanning and Terraform validation gates.
- Validated Terraform for Azure App Service, SQL, Storage, Key Vault, managed identity, and monitoring.
- Evidence library, issue backlog, and staged cloud roadmap.

The remaining execution milestone is to retain the first GitHub artifacts for the new QA/container gates and, separately, review an Azure plan before any cost-bearing deployment. No Azure resources are claimed as deployed.

---

# 2. Project Overview and Objectives

## Problem

Source code alone did not answer the questions a new engineer needs:

- Which dependencies must run?
- Which settings are secrets?
- How is the database created?
- Which routes are public?
- Which roles should receive 401, 403, or 200?
- How can uploads run without Azure?
- Which failures are code defects versus environment failures?
- What automated checks protect a pull request?
- How can SQL behavior be observed?

## Objective

Transform an existing .NET and SQL Server backend into a documented QA, DevOps, DevSecOps, observability, and cloud-readiness lab while preserving original attribution.

## Success Criteria

- Clean checkout restores and builds.
- Migrations create the expected schema.
- User, Host, and Admin workflows operate correctly.
- Property creation, approval, listing, filtering, and ownership work.
- Public reads remain public.
- Protected mutations return correct authorization statuses.
- CI and security checks run independently of local machines.
- Grafana observes SQL Server through restricted permissions.
- A newcomer can diagnose setup problems using repository documentation.

## Ownership and Attribution

The original Sakenny backend was produced by an ITI Alexandria Full Stack Development Track team and remains MIT-licensed. Original credits are retained in the README and LICENSE.

This portfolio claims the environment reconstruction, testing, documented defect investigation, selected fixes, CI/security automation, dependency review, Grafana integration, least-privilege database configuration, evidence, and roadmap. It does not claim authorship of the original domain or present planned cloud work as completed.

---

# 3. Architecture and Technical Stack

~~~text
Swagger / API client / frontend
             |
             v
      ASP.NET Core 8 API
       |             |
       v             v
Identity + JWT   Application services
       |             |
       +------ EF Core
                    |
                    v
              SQL Server

API -> ImageService -> BlobService -> Azurite
Grafana container -> host.docker.internal:1433 -> SQL Server
GitHub -> Build / CodeQL / Gitleaks / Dependabot
~~~

| Area | Technology | Purpose |
| --- | --- | --- |
| API | ASP.NET Core 8 / C# | HTTP application |
| Data | EF Core 8 / SQL Server | Persistence and migrations |
| Identity | ASP.NET Identity / JWT | Authentication and roles |
| Storage | Azure Blob SDK / Azurite | Images and local emulation |
| API documentation | Swagger/OpenAPI | Manual validation |
| CI/CD foundation | GitHub Actions | Build and security gates |
| Supply chain | Dependabot | Dependency update PRs |
| SAST | CodeQL | C# security analysis |
| Secret detection | Gitleaks | Repository scanning |
| Observability | Grafana / Docker Compose | SQL dashboards |
| Planned QA | Postman / Newman / xUnit | Automated regression |
| Planned cloud | Terraform / Azure | Infrastructure as code |

The principal roles are User, Host, and Admin. Roles are created at application startup. Important relationships include users-to-roles, properties-to-types, properties-to-images, properties-to-permits, and properties-to-services through PropertyServices.

## Security Boundaries

The lab separates anonymous API access, authenticated role access, API-to-database access, API-to-storage access, Grafana-to-database monitoring, GitHub runner permissions, and future Azure service identities.

Real JWT keys, database passwords, Grafana credentials, Stripe secrets, Google secrets, and cloud credentials must not be committed. Local .NET secrets belong in User Secrets; container credentials belong in ignored environment files; future Azure secrets belong in Key Vault accessed through managed identity.

---

# 4. Implementation and Engineering Challenges

## Authentication Middleware

**Symptom:** Protected routes returned unauthorized responses or did not resolve roles correctly.

**Root cause:** Authorization ran before authentication established the request principal.

**Fix:**

~~~csharp
app.UseAuthentication();
app.UseAuthorization();
~~~

**Validation:** Admin dashboard and role-conversion routes worked; Host property routes worked; public reads remained accessible.

## Services API Contract

**Symptom:** POST /api/Services failed although direct SQL inserts succeeded.

**Root cause:** Service.Icon was required by persistence but absent from AddServiceDTO.

**Fix:** Add and map Icon in the create contract.

**Validation:** Admin created Sauna with icon sauna; GET and SQL returned the row; properties could reference API-created services.

## Public Lookup Mutations

**Symptom:** Anonymous callers could modify Type and Service data.

**Fix:** Preserve public reads and restrict create, update, and delete to Admin.

~~~text
Anonymous mutation -> 401
Host mutation      -> 403
Admin mutation     -> 200
Anonymous read     -> 200
~~~

This matrix proves authentication and authorization separately.

## Dependency Conflict

Dependabot conflict resolution left duplicate Azure.Storage.Blobs references. A post-merge audit removed the obsolete line and CI validated the cleaned project. The lesson was that green automation still requires human review.

## Storage Constructor Coupling

BlobService originally performed external work while dependencies were constructed:

~~~text
UserController -> UserService -> ImageService
               -> BlobService constructor -> storage connection
~~~

Container creation now occurs only inside the awaited upload operation. An xUnit regression test proves that constructing `BlobService` with development-storage configuration does not contact Azurite. This decouples unrelated controller activation from storage availability.

## Anonymous Admin Registration

`/AdminRegister` originally allowed an unauthenticated caller to create the highest application role. The route now requires Admin authorization. Fresh environments use explicit `BootstrapAdmin` settings; local values come from an ignored `.env`, CI uses isolated test values, and the Azure design references Key Vault.

---

# 5. CI, DevSecOps, and Observability

## CI Foundation

The .NET workflow checks out source, selects .NET 8, restores the solution, builds Release configuration, runs xUnit, and retains TRX results with read-only repository permission. A separate smoke workflow launches SQL Server and Azurite service containers, starts the API, executes Newman, and retains JUnit output.

Dependabot monitors NuGet and GitHub Actions. Updates should be merged individually after review. Major framework versions require coordinated compatibility work, not automatic acceptance.

## Security Controls

CodeQL runs C# security and quality queries on pull requests, selected branches, and a weekly schedule. Gitleaks scans full history on pushes, pull requests, manual runs, and schedule.

When a scanner finds a real secret, deleting the line is insufficient. Rotate the credential, investigate exposure, replace it with safe configuration, and re-run the scan.

Trivy now builds and scans the API image for High and Critical findings. Terraform formatting and validation run on infrastructure changes. Future controls include deeper database-backed integration tests, an SBOM where useful, and OWASP ZAP against a stable test target.

## SQL Observability

Grafana runs in Docker and reaches Windows SQL Server through:

~~~text
host.docker.internal:1433
~~~

The dashboard shows sessions, connections, database states, error/security counters, I/O, space, indexes, and query activity. A dedicated grafana_reader account receives scoped permissions instead of sysadmin.

~~~sql
USE master;
GRANT VIEW SERVER STATE TO grafana_reader;
GRANT VIEW ANY DATABASE TO grafana_reader;

USE SakennyDB;
ALTER ROLE db_datareader ADD MEMBER grafana_reader;
GRANT VIEW DATABASE STATE TO grafana_reader;
~~~

Selected msdb objects receive explicit SELECT grants for job panels. A panel showing No data can be valid when the local database has no matching jobs, backups, or workload; it is different from a query error.

The dashboard was adapted from the MIT-licensed project at:

https://github.com/czantoine/microsoft-sql-server-with-grafana

---

# 6. Impact and Results

| Measure | Result |
| --- | --- |
| Fresh-clone build | 0 errors |
| Warning baseline | 224 known warnings |
| Application/security defects fixed and checked | 5 |
| Dependency configuration fixes | 1 |
| Roles validated | User, Host, Admin |
| Authorization outcomes | 401, 403, 200 |
| Admin dashboard routes manually validated | 7 |
| GitHub automation workflows | 7 |
| xUnit regression tests | 11 |
| Postman/Newman smoke requests | 16 |
| Dependabot ecosystems | NuGet and GitHub Actions |
| Grafana evidence images | 3 |
| Monitoring access | 1 least-privilege SQL identity |

Before the work, setup knowledge was fragmented, API and SQL validation were disconnected, pull requests lacked quality/security feedback, and database behavior was not visible.

After the work, newcomers have a defined setup path, role behavior has explicit expected outcomes, defects have evidence and regression criteria, pull requests receive automated checks, dependencies are surfaced automatically, and SQL Server has version-controlled monitoring.

Evidence:

- docs/evidence/github-pr-queue-cleared.png
- docs/evidence/grafana-sql-dashboard-overview.png
- docs/evidence/grafana-sql-dashboard-security-monitoring.png
- docs/evidence/grafana-sql-dashboard-index-health.png

Evidence must never expose credentials or tokens and must be paired with written test scope.

---

# 7. Newcomer Setup Guide

## Prerequisites

Install Git, .NET 8 SDK, SQL Server Express/Developer, SSMS, Docker Desktop, PowerShell, and an editor. Postman, Node.js, and Newman are needed in the next phase.

## Clone and Build

~~~powershell
git clone https://github.com/Juaaanits/sakenny-backend-qa-devsecops-cloud-lab.git
cd sakenny-backend-qa-devsecops-cloud-lab
dotnet restore .\sakenny.sln
dotnet build .\sakenny.sln --configuration Release --no-restore
~~~

## Configure Local Secrets

~~~powershell
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=.\SQLEXPRESS;Database=SakennyDB;Trusted_Connection=True;TrustServerCertificate=True;" --project .\sakenny\sakenny.csproj
dotnet user-secrets set "AzureBlobStorage:ConnectionString" "UseDevelopmentStorage=true" --project .\sakenny\sakenny.csproj
dotnet user-secrets set "AzureBlobStorage:containerName" "images" --project .\sakenny\sakenny.csproj
dotnet user-secrets set "Jwt:Issuer" "sakenny-local" --project .\sakenny\sakenny.csproj
dotnet user-secrets set "Jwt:Audience" "sakenny-local-client" --project .\sakenny\sakenny.csproj
dotnet user-secrets set "Jwt:Key" "replace-with-a-long-random-local-key" --project .\sakenny\sakenny.csproj
dotnet user-secrets set "Jwt:RefreshTokenExpiryDays" "7" --project .\sakenny\sakenny.csproj
~~~

## Start Dependencies and API

~~~powershell
docker run --rm -it -p 10000:10000 -p 10001:10001 -p 10002:10002 --name sakenny-azurite mcr.microsoft.com/azure-storage/azurite
~~~

In another terminal:

~~~powershell
dotnet ef database update --project .\sakenny\sakenny.csproj --startup-project .\sakenny\sakenny.csproj
dotnet run --project .\sakenny\sakenny.csproj --launch-profile https
~~~

Open https://localhost:7279/swagger/index.html.

## Validation Sequence

1. Register User and Admin.
2. Verify role rows in SQL Server.
3. Convert User to Host and log in again.
4. Create Type and Service as Admin.
5. Create Property as Host.
6. Verify Properties, Images, PropertyPermits, snapshots, and PropertyServices.
7. Approve Property as Admin.
8. Validate public list, detail, and filter.
9. Validate owned properties as Host.
10. Validate dashboard as Admin.
11. Execute the 401/403/200 matrix.

For important workflows verify the HTTP response, resulting database state, and a later read response.

## Start Grafana

~~~powershell
cd .\monitoring\grafana
Copy-Item .env.example .env
docker compose up -d
~~~

Edit only the ignored local .env, then open http://localhost:3000.

---

# 8. Troubleshooting and Operations

| Symptom | First check |
| --- | --- |
| Restore fails | Network and NuGet source |
| Build fails | dotnet --info and package versions |
| API exits | First console exception and User Secrets |
| Migration fails | SQL service, instance, connection |
| Registration fails without storage | Azurite and BlobService coupling |
| Swagger returns 401 | Token expiry and duplicated Bearer |
| Host receives 403 after conversion | Log in again |
| Service create fails | Required Icon |
| Grafana connection refused | Test-NetConnection localhost -Port 1433 |
| Grafana login failed | SQL authentication and user mapping |
| SELECT denied | Missing scoped grant |
| Panel says No data | Time range and actual workload |

Before a pull request:

~~~powershell
git status --short
dotnet restore .\sakenny.sln
dotnet build .\sakenny.sln --configuration Release --no-restore
git diff --check
~~~

Also run relevant positive/negative checks, confirm no secret file is tracked, update evidence, and document limitations.

---

# 9. Limitations and Roadmap

Current limitations:

- The full Newman suite has not yet been retained from its first GitHub run.
- xUnit coverage is focused on authorization metadata and storage construction, not all business services.
- 224 warnings remain as technical debt.
- Routes are inconsistent.
- Grafana image is not pinned.
- Cloud deployment, SLOs, backup policy, and alerts are not implemented.

## Recommended Sequence

1. Retain green xUnit, Newman, Trivy, and Terraform artifacts from GitHub Actions.
2. Add database-backed integration tests for high-risk services.
3. Resolve nullable and EF model warnings with regression checks.
4. Add OWASP ZAP against a stable test environment.
5. Review Azure cost, networking, Terraform plan, and deployment approvals.
6. Provision a temporary Azure environment and run post-deployment smoke tests only after approval.
7. Add k6 performance tests correlated with Grafana and Query Store.

Terraform quality gates:

~~~text
terraform fmt -check
terraform init
terraform validate
terraform plan
~~~

State and secrets must not be committed.

---

# 10. Portfolio Positioning

## One-Sentence Description

An inherited ASP.NET Core and SQL Server backend transformed into a documented QA, DevSecOps, and observability lab with role-based API validation, CI security controls, and least-privilege database monitoring.

## Resume Bullets

- Validated and hardened an MIT-licensed ASP.NET Core 8 and SQL Server backend by reproducing its environment, testing JWT role workflows, diagnosing API/persistence defects, and documenting 401/403/200 regression evidence.
- Implemented GitHub Actions, Dependabot, CodeQL, Gitleaks, Trivy, xUnit, Postman/Newman, and a reproducible Docker Compose stack; provisioned least-privilege Grafana SQL monitoring and validated Terraform for an Azure managed-identity architecture.

## Interview Narrative

**Situation:** An inherited backend had useful functionality but limited operational documentation and automation.

**Task:** Make it reproducible, testable, secure, and observable without rewriting it or overstating ownership.

**Action:** Reconstructed SQL Server and Azurite, validated API/data flows, fixed authentication and authorization defects, added CI/security workflows, and provisioned Grafana with restricted SQL access.

**Result:** The repository builds with zero errors, has automated build/security feedback, documents role regressions, and provides onboarding and observability evidence. Remaining warnings and planned automation are recorded honestly.

## Lessons Learned

- Reproduce before changing code.
- Verify requests across API, service, and database layers.
- Negative tests explain security better than successful requests alone.
- Dependency automation still needs human review.
- Least privilege is stronger than administrative shortcuts.
- Honest boundaries between completed and planned work increase credibility.

---

# 11. PDF Compilation Plan

For a full handbook, compile in this order:

1. This master case study.
2. [Local Setup and Validation](LOCAL_SETUP_AND_VALIDATION.md)
3. [API Test Runbook](API_TEST_RUNBOOK.md)
4. [Known Issues and Fix Plan](KNOWN_ISSUES_AND_FIX_PLAN.md)
5. [SQL Server Test Notes](SQL_SERVER_TEST_NOTES.md)
6. [Grafana Observability Guide](OBSERVABILITY_SQL_SERVER_GRAFANA.md)
7. [DevOps and DevSecOps Checklist](DEVOPS_DEVSECOPS_CHECKLIST.md)
8. [QA, DevSecOps, and Cloud Roadmap](QA_DEVSECOPS_CLOUD_ROADMAP.md)
9. [Automated QA and Container Runbook](AUTOMATED_QA_AND_CONTAINER_RUNBOOK.md)
10. [Terraform and Azure Deployment Guide](TERRAFORM_AZURE_DEPLOYMENT.md)
11. [Final Project Status](FINAL_PROJECT_STATUS.md)
12. [Reference Links](REFERENCE_LINKS.md)

The repository includes a reproducible compiler:

~~~powershell
.\scripts\build-portfolio.ps1
# Add -Pdf when Pandoc and a PDF engine are installed.
~~~

It writes a single combined Markdown book and optional HTML/PDF files under ignored `artifacts/portfolio/`.

Recommended PDF front matter:

~~~text
Cover
Author and repository
Version/date
Table of contents
Executive summary
~~~

Recommended appendix material:

~~~text
Evidence screenshots
API authorization matrix
SQL verification queries
Incident/RCA template
Test evidence template
Glossary and references
~~~

## Reusable Test Evidence Template

~~~text
Test ID:
Date and commit:
Environment:
Preconditions:
Request or command:
Expected result:
Actual result:
HTTP status:
Database verification:
Artifact:
Pass or fail:
Notes:
~~~

## Reusable RCA Template

~~~text
Summary and impact:
Detection:
Symptoms:
Evidence:
Root cause:
Contributing factors:
Containment:
Resolution:
Validation:
Preventive action:
Owner and target date:
~~~

## Primary References

- ASP.NET Core authorization: https://learn.microsoft.com/en-us/aspnet/core/security/authorization/introduction
- User Secrets: https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets
- GitHub Actions: https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
- Dependabot: https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference
- CodeQL: https://docs.github.com/en/code-security/concepts/code-scanning/codeql/codeql-code-scanning
- Gitleaks: https://github.com/gitleaks/gitleaks
- Newman: https://learning.postman.com/docs/reference/newman-cli/command-line-integration-with-newman
- Grafana MSSQL: https://grafana.com/docs/grafana/latest/datasources/mssql/configure/
- Terraform on Azure: https://learn.microsoft.com/en-us/azure/developer/terraform/

---

# Conclusion

This project demonstrates a practical progression: understand an inherited service, reproduce it, test it, diagnose it, secure it, automate it, observe it, and prepare it for cloud delivery.

Its strongest result is combined application, database, security, and operations evidence. Authentication fixes were validated through roles. Contract fixes were validated through persistence. CI was paired with dependency review. Grafana access was solved with scoped permissions instead of administrative shortcuts.

The project is portfolio-ready as a completed local QA, DevSecOps, observability, container-readiness, and infrastructure-validation phase. Actual Azure provisioning and runtime evidence remain a separate credential- and budget-dependent stage.
