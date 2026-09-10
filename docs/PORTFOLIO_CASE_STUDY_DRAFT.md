# Portfolio Case Study Draft

Project name:

```text
Sakenny Backend QA, DevSecOps, and Cloud Engineering Lab
```

## Short Resume Version

Validated and extended an MIT-licensed ASP.NET Core property rental backend as an Automation QA, DevSecOps, and Cloud Engineering portfolio project. Reproduced the local environment with SQL Server and Azurite, verified JWT role-based workflows through Swagger, documented API test paths, identified backend defects, added an initial GitHub Actions build quality gate, enabled Dependabot dependency monitoring, and created a roadmap for automated testing, security scanning, SQL Server performance tuning, Docker, Terraform, and Azure deployment.

## Interview Explanation

I wanted a project that was closer to real engineering work than a fresh CRUD app. I cloned an existing MIT-licensed .NET 8 backend, preserved attribution to the original authors, and treated it like a system I had inherited at work.

My first goal was not to rewrite code. I focused on getting the backend running locally and proving the main workflows. I configured SQL Server, applied EF Core migrations, started Azurite for local blob storage, ran the API through Swagger, created users and roles, tested JWT authorization, created and approved properties, uploaded images, tested filtering, and validated the database tables directly.

During that process I found practical issues: missing authentication middleware, a Services API contract mismatch, public mutation endpoints, hardcoded secrets, route inconsistencies, and infrastructure coupling caused by blob storage initialization. I fixed and validated the first authorization/API contract issues, then documented the remaining backlog with impact, planned fix, and validation criteria so the project can evolve through controlled improvements.

The next phase is to extend the CI pipeline with automated API tests, CodeQL, secret scanning, and container scanning, then containerize the backend, deploy it to Azure with Terraform, and measure SQL Server performance before and after database tuning.

## What I Have Proven So Far

```text
.NET 8 backend runs locally
SQL Server migrations apply successfully
ASP.NET Identity roles are created
JWT login works
Admin authorization works
Host authorization works
Azurite image upload works
Property creation works
Admin property approval works
Property-service relationship works
Public property listing works
Property filtering works
Host-owned property endpoint works
Admin dashboard endpoints work
Services API creates Name + Icon through the API
Type and Services mutation endpoints enforce 401/403/200 authorization behavior
GitHub Actions restore/build workflow passes
Dependabot creates dependency update PRs for GitHub Actions and NuGet packages
```

## Defects Discovered Through Testing

```text
Missing authentication middleware in the ASP.NET request pipeline
Services API cannot create a row because Icon is required but missing from the create DTO
Type and Services mutation endpoints are not protected by Admin authorization
Blob storage is initialized during dependency construction, affecting unrelated endpoints
Several routes use absolute paths, making the API less consistent
Secrets and sensitive config should move out of appsettings.json
EF Core warnings indicate model configuration cleanup is needed
Nullable warnings indicate dashboard hardening is needed
```

## Fixes Validated So Far

```text
Added authentication middleware before authorization in the request pipeline
Updated Services API contract so service creation includes Icon
Protected Type and Services POST/PUT/DELETE endpoints with Admin authorization
Validated no-token, Host-token, and Admin-token behavior with 401/403/200 responses
Added GitHub Actions .NET restore/build validation
Enabled Dependabot monitoring for NuGet and GitHub Actions dependencies
```

## CI And Dependency Monitoring Evidence

```text
.NET CI workflow passed after the CI branch was merged.
Dependabot opened automated PRs for actions/checkout and actions/setup-dotnet.
Dependabot opened automated PRs for AutoMapper and Azure SDK NuGet packages.
The Dependabot PR list showed 2/2 checks passing before merge review.
```

Review note:

```text
GitHub Actions version bumps are low-risk when CI passes.
Azure SDK patch/minor updates should be merged one at a time after CI passes.
AutoMapper 15.0.1 to 16.2.0 is a major version update and should be followed by local API smoke testing.
```

## Why This Project Fits My Target Roles

Automation QA:

```text
API test design
Positive and negative endpoint coverage
Regression test planning
Postman/Newman automation path
Integration test roadmap
Evidence-based bug reporting
```

DevSecOps:

```text
Secret management
Role-based access validation
SAST/dependency/container scanning roadmap
CI/CD quality gates
Dependabot dependency monitoring
Security hardening backlog
OWASP-style validation plan
```

Cloud Engineering:

```text
Azure Blob/Azurite storage understanding
Azure SQL deployment path
Key Vault and managed identity roadmap
Terraform infrastructure plan
Monitoring and observability roadmap
```

SQL Server:

```text
Schema validation
Relationship checks
Query and endpoint mapping
Performance baseline plan
Index tuning hypotheses
Measured before/after optimization plan
```

## Next Measurable Outcomes

```text
Add Postman collection and Newman CI run
Add xUnit integration tests for auth and property flows
Add Docker Compose for API dependencies
Extend GitHub Actions CI with tests and security scans
Create SQL Server performance baseline report
Deploy to Azure with Terraform
Add monitoring dashboard and alerting notes
```
