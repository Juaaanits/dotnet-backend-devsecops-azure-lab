# QA, DevSecOps, and Cloud Roadmap

This roadmap turns the Sakenny backend clone into a portfolio project for Automation QA, DevSecOps, Cloud Engineering, and SQL Server validation.

## Project Positioning

This is not just a cloned CRUD backend. The engineering goal is:

```text
Take an existing .NET and SQL Server application, validate it locally, identify defects, automate its quality gates, harden its security posture, containerize it, deploy it to Azure, and monitor it like a production service.
```

That positioning demonstrates practical ownership of an existing system, which is closer to real engineering work than starting from an empty template.

## Phase 1: Manual Baseline Validation

Status: completed.

Deliverables:

```text
Local setup notes
SQL Server validation queries
Swagger endpoint validation
JWT role testing
Azurite image upload validation
Known issue backlog
```

Evidence already collected:

```text
Roles created in AspNetRoles
Users and role assignments created through Identity
PropertyTypes created
Services inserted as workaround
Properties created through /AddProperty
Image URLs created through Azurite
PropertyServices relationships verified
Admin approval verified
Public listing/filter/details verified
Dashboard endpoints verified
CodeQL scanning merged
Grafana SQL Server dashboard connected to SakennyDB
```

## Phase 2: Bug Fixes With Regression Checks

Target fixes:

```text
Services API Icon mismatch
Admin-only protection for Type and Services mutations
BlobService constructor side effect
Secrets moved out of appsettings
Route consistency improvements
EF model warnings
Dashboard nullable warnings
```

For each fix, document:

```text
Problem
Root cause
Change
Validation
Before/after screenshots or logs
Regression test added
```

## Phase 3: API Test Automation

Status: baseline implemented. Expansion remains ongoing.

Recommended stack:

```text
Postman collection for manual and automated API checks
Newman for CI execution
xUnit for service/integration tests
WebApplicationFactory for ASP.NET Core integration tests
Testcontainers or Docker Compose for SQL Server and Azurite test dependencies
```

Core API scenarios to automate:

```text
Register user
Login user
Verify anonymous Admin registration is rejected
Login bootstrap Admin
Login admin
Convert user to Host
Create property type
Create service
Create property with image upload
Approve property
List all properties
Filter properties
View property details
Get host-owned properties
Get dashboard stats
Reject unauthorized access
Reject invalid payloads
```

Quality gates:

```text
Build must pass
Unit tests must pass
Integration tests must pass
Postman/Newman smoke collection must pass
No secrets detected
Dependency scan reviewed
Container scan reviewed
```

## Phase 4: SQL Server Performance Work

Approach:

```text
Baseline first.
Create realistic test data.
Measure actual query behavior.
Apply one optimization at a time.
Measure again.
Document the result.
```

Target workloads:

```text
Property search/filter
Property detail loading
Host-owned property list
Dashboard aggregations
Renting/booking date checks
Review aggregation
```

Metrics:

```text
Execution time
Logical reads
CPU time
Query plan shape
Missing index warnings
Waits and blocking
p50/p95/p99 latency from API tests
```

Recruiter-facing evidence:

```text
Before/after query plans
Before/after STATISTICS IO output
Endpoint latency before/after
Explanation of why an index was selected
Explanation of why an advanced option was rejected if it did not fit the data
```

## Phase 5: DevSecOps Pipeline

Current baseline implemented:

```text
GitHub Actions restore/build quality gate
Dependabot monitoring for NuGet dependencies
Dependabot monitoring for GitHub Actions versions
CodeQL C# SAST scanning
Gitleaks secret scanning
Grafana SQL Server observability dashboard
xUnit regression tests and retained TRX configuration
Postman/Newman smoke workflow and JUnit configuration
Docker Compose dependency/application stack
Trivy container scanning workflow
Terraform formatting and validation workflow
Manual Azure OIDC deployment workflow
```

Evidence collected:

```text
.NET CI workflow passed.
Dependabot opened update PRs for GitHub Actions and NuGet packages.
Dependabot PRs showed 2/2 passing checks before review.
The first Dependabot PR queue was later cleared to 0 open pull requests.
Duplicate Azure.Storage.Blobs package reference was cleaned after conflict resolution.
CodeQL workflow merged after repository code scanning was enabled.
Grafana dashboard connected to the local SakennyDB datasource.
```

Evidence screenshot:

```text
docs/evidence/github-pr-queue-cleared.png
```

Post-merge cleanup item:

```text
Completed. The duplicate Azure.Storage.Blobs package reference left after dependency conflict resolution was removed.
The project now keeps Azure.Storage.Blobs 12.29.2.
```

Target pipeline:

```text
GitHub
  -> Build
  -> Unit tests
  -> Integration tests
  -> Secret scanning
  -> Dependency scanning
  -> SAST
  -> Docker build
  -> Container scan
  -> Publish artifact/image
  -> Deploy to staging
  -> Smoke tests
```

Candidate tools:

```text
GitHub Actions
dotnet test
Newman
Gitleaks
CodeQL
Dependabot
Trivy
OWASP ZAP baseline scan
Docker
Azure Container Registry
```

Security improvements:

```text
Clean duplicate dependency references after automated update conflict resolution
Move secrets to user-secrets locally
Use environment variables in CI
Use Azure Key Vault in Azure
Enforce HTTPS
Review CORS policy
Protect admin mutations
Add structured error handling
Add request logging and correlation IDs
```

## Phase 6: Cloud Deployment

Status: Terraform and deployment workflow implemented and validated statically; Azure plan/apply and runtime evidence pending credentials, budget approval, and security review.

Target Azure architecture:

```text
Internet
  -> Azure Application Gateway + WAF
  -> Azure App Service or containerized API
  -> Azure SQL
  -> Azure Blob Storage
  -> Azure Key Vault
  -> Azure Monitor + Application Insights
```

Infrastructure as Code:

```text
Terraform resource group
Azure SQL server/database
Storage account and blob container
App Service plan and app
Key Vault
Managed identity
Application Insights
Diagnostic settings
Staging and production variables
Remote state
```

Deployment evidence:

```text
Terraform plan/apply screenshots
GitHub Actions deployment run
App Service health check
Smoke test result
Application Insights request traces
Azure SQL metrics
Key Vault references working
```

## Phase 7: Load and Reliability Testing

Candidate tools:

```text
k6
JMeter
Postman runner
Azure Load Testing
```

Scenarios:

```text
Read-heavy property listing
Filtered property search
Concurrent logins
Property detail reads
Dashboard reads
Booking conflict attempts
Image upload limits
```

Metrics:

```text
Requests per second
p50 latency
p95 latency
p99 latency
Error rate
CPU
Memory
SQL waits
Connection pool behavior
```

## Portfolio Evidence Checklist

Create these artifacts as the project matures:

```text
README with honest project scope and attribution
Local setup report
API test runbook
Known issues and fix plan
DevOps and DevSecOps checklist
Postman collection
Automated test results
CI/CD pipeline screenshot with green .NET CI run
Dependabot PR screenshot showing automated dependency updates and passing checks
SQL performance report
Security scan report
Docker Compose setup
Terraform architecture
Azure deployment notes
Monitoring dashboard screenshots
Grafana SQL Server dashboard JSON and provisioning files
Final case study
```

## Final Case Study Template

Use this structure when the improvement work is complete:

```text
Problem:
The cloned backend had no documented local validation process, incomplete API test coverage, secrets/configuration risks, and several runtime/API issues.

Action:
I established a reproducible SQL Server + Azurite local environment, validated critical role-based API workflows, fixed discovered issues, introduced an initial CI build gate, enabled dependency monitoring, CodeQL, and Gitleaks scanning, added a local Grafana SQL Server dashboard, and prepared the backlog for automated tests, SQL performance work, and Azure deployment infrastructure.

Result:
The backend moved from manually tested clone to documented, testable, cloud-ready engineering project with measurable quality and security improvements.
```
