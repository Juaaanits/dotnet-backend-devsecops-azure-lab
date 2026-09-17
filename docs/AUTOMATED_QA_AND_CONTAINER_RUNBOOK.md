# Automated QA and Container Runbook

This runbook explains the automated regression suite and the reproducible local stack added around the Sakenny API.

## What Is Included

| Component | Location | Purpose |
| --- | --- | --- |
| xUnit tests | `tests/Sakenny.Tests` | Authorization metadata and storage-constructor regression checks |
| Postman collection | `postman/Sakenny.postman_collection.json` | End-to-end API and role smoke tests |
| Newman wrapper | `scripts/test-smoke.ps1` | CLI execution and JUnit report generation |
| Docker Compose | `docker-compose.yml` | SQL Server, Azurite, API, SQL initialization, and Grafana |
| Local scripts | `scripts/dev-*.ps1` | Start, stop, and inspect the stack |
| CI smoke workflow | `.github/workflows/api-smoke.yml` | Linux-hosted API and Newman regression run |

## Security Model Used by the Tests

The public `/AdminRegister` path is protected with the Admin role. A first administrator is created only when all three `BootstrapAdmin` values are configured. Existing environments with an Admin account do not need bootstrap configuration.

The smoke suite verifies:

```text
Anonymous public read       -> 200
Anonymous protected write   -> 401
User attempting Admin write -> 403
Host owned-property read    -> 200
Host dashboard read         -> 403
Admin protected operations  -> 200
```

Bootstrap credentials in `.env.example` are development examples only. Change them in the ignored `.env` file. Never reuse them outside the local lab.

## Run xUnit Tests

```powershell
dotnet restore .\sakenny.sln
dotnet test .\sakenny.sln --configuration Release
```

The tests intentionally avoid a live database. They inspect controller authorization metadata and ensure `BlobService` construction no longer contacts storage.

## Start the Full Local Stack

Prerequisites: Docker Desktop with Linux containers and PowerShell 7 or Windows PowerShell.

```powershell
Copy-Item .env.example .env
```

Edit `.env` and replace every placeholder password or key. Then run:

Generate a local-only Azurite key and place the output in `AZURITE_ACCOUNT_KEY`:

```powershell
[Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(64))
```

The value remains only in ignored `.env`; the same value configures Azurite and the API connection string.

Then run:

```powershell
.\scripts\dev-up.ps1
docker compose ps
```

Default endpoints:

```text
API health: http://localhost:5111/health
Swagger:    http://localhost:5111/swagger/index.html
Grafana:    http://localhost:3000
SQL Server: localhost,14330
```

SQL Server uses host port `14330` by default so it does not conflict with an existing Windows SQL Server on `1433`. Container-to-container traffic still uses `sqlserver:1433`.

Inspect or stop the environment:

```powershell
.\scripts\dev-logs.ps1
.\scripts\dev-down.ps1
```

Use `docker compose down --volumes` only when intentionally deleting local lab data.

## Run the Postman Collection with Newman

With the Compose stack healthy:

```powershell
.\scripts\test-smoke.ps1
```

The script uses `npx newman`, the example environment, and writes a JUnit report under ignored `artifacts/newman/`. The collection creates a timestamped User, logs in, verifies JWT role behavior, promotes the User to Host through an Admin call, and checks public and protected routes.

To run directly:

```powershell
npx --yes newman run .\postman\Sakenny.postman_collection.json `
  --environment .\postman\Sakenny.postman_environment.json.example `
  --reporters cli,junit `
  --reporter-junit-export .\artifacts\newman\results.xml
```

## CI Behavior

`dotnet-ci.yml` builds and runs xUnit tests, then retains TRX results. `api-smoke.yml` starts SQL Server and Azurite service containers, launches the API with CI-only configuration, waits for `/health`, executes Newman, and retains the JUnit report.

`container-security.yml` builds the API image and blocks High or Critical Trivy findings. A finding must be assessed before suppression; suppressions require a reason, owner, and expiry date.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Docker daemon unavailable | Start Docker Desktop and confirm `docker info` succeeds |
| Port already allocated | Change `MSSQL_HOST_PORT`, `API_HOST_PORT`, or `GRAFANA_HOST_PORT` in `.env` |
| SQL container unhealthy | Password complexity and `docker compose logs sqlserver` |
| API unhealthy | Database migration output and `docker compose logs api` |
| Admin login fails | All three `BOOTSTRAP_ADMIN_*` values and API startup logs |
| Newman gets 401 | Bootstrap email/password match the environment file |
| Newman gets 403 after promotion | Re-login occurred so the JWT contains the Host role |
| Grafana panels fail | `sql-init` completed and `grafana_reader` grants exist |

## Evidence to Retain

Retain the GitHub Actions run URL, xUnit TRX artifact, Newman JUnit artifact, Trivy result, commit SHA, and one sanitized Grafana screenshot. Do not retain tokens, passwords, connection strings, or raw `.env` files.

## Official References

- [.NET testing with `dotnet test`](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-test)
- [Postman Newman CLI](https://learning.postman.com/docs/collections/using-newman-cli/command-line-integration-with-newman/)
- [Docker Compose](https://docs.docker.com/compose/)
- [GitHub Actions service containers](https://docs.github.com/en/actions/use-cases-and-examples/using-containerized-services/about-service-containers)
- [Trivy GitHub Action](https://github.com/aquasecurity/trivy-action)
