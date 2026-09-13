# SQL Server Observability With Grafana

This document records the local SQL Server monitoring setup added for the Sakenny backend lab.

Status: completed locally on 2026-09-13.

## Purpose

The goal is to prove operational visibility for the backend database, not just API correctness.

This setup monitors the local SQL Server instance used by Sakenny through Grafana's Microsoft SQL Server datasource. It is useful for QA, DevSecOps, and cloud engineering because it turns database health, permissions, sessions, waits, query behavior, and storage usage into visible evidence.

## Added Files

```text
monitoring/grafana/docker-compose.yml
monitoring/grafana/.env.example
monitoring/grafana/provisioning/datasources/mssql.yml
monitoring/grafana/provisioning/dashboards/dashboards.yml
monitoring/grafana/dashboards/sakenny-sql-server-dashboard.json
docs/evidence/grafana-sql-dashboard-overview.png
docs/evidence/grafana-sql-dashboard-security-monitoring.png
docs/evidence/grafana-sql-dashboard-index-health.png
```

Local secrets are intentionally kept out of git:

```text
monitoring/grafana/.env
```

## Start Grafana

From the repository root:

```powershell
cd .\monitoring\grafana
Copy-Item .env.example .env
docker compose up -d
```

Before starting Grafana, edit `.env` with local-only values for the Grafana admin password and SQL Server `grafana_reader` password.

Open Grafana:

```text
http://localhost:3000
```

The datasource is provisioned automatically from:

```text
monitoring/grafana/provisioning/datasources/mssql.yml
```

The dashboard is provisioned automatically from:

```text
monitoring/grafana/dashboards/sakenny-sql-server-dashboard.json
```

## SQL Server Requirements

For Dockerized Grafana to connect to SQL Server running on Windows:

```text
SQL Server service is running.
TCP/IP is enabled in SQL Server Configuration Manager.
SQL Server listens on port 1433.
SQL Server Authentication is enabled.
Grafana uses host.docker.internal:1433.
The target database is SakennyDB.
```

## Monitoring Login

Use a dedicated read-only monitoring login. Do not use `sa`, `db_owner`, or `sysadmin` for Grafana.

Example local setup:

```sql
USE master;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.sql_logins
    WHERE name = 'grafana_reader'
)
BEGIN
    CREATE LOGIN grafana_reader WITH PASSWORD = 'replace-with-local-password';
END
GO

GRANT VIEW SERVER STATE TO grafana_reader;
GRANT VIEW ANY DATABASE TO grafana_reader;
GO
```

For SQL Server versions that require the newer performance permission:

```sql
USE master;
GO

GRANT VIEW SERVER PERFORMANCE STATE TO grafana_reader;
GO
```

Database-level access:

```sql
USE SakennyDB;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'grafana_reader'
)
BEGIN
    CREATE USER grafana_reader FOR LOGIN grafana_reader;
END
GO

ALTER ROLE db_datareader ADD MEMBER grafana_reader;
GRANT VIEW DATABASE STATE TO grafana_reader;
GO
```

SQL Agent job panels read from `msdb`. Grant only the specific objects needed by the dashboard:

```sql
USE msdb;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'grafana_reader'
)
BEGIN
    CREATE USER grafana_reader FOR LOGIN grafana_reader;
END
GO

GRANT SELECT ON dbo.sysjobhistory TO grafana_reader;
GRANT SELECT ON dbo.sysjobs TO grafana_reader;
GRANT SELECT ON dbo.sysjobactivity TO grafana_reader;
GRANT SELECT ON dbo.sysjobschedules TO grafana_reader;
GRANT SELECT ON dbo.sysschedules TO grafana_reader;
GO
```

This keeps the monitoring user narrow while allowing the dashboard to read database state, server performance metadata, and job history.

## Validation Completed

Validated locally:

```text
Grafana container starts through Docker Compose.
Grafana datasource connects to SQL Server.
Datasource uses host.docker.internal:1433.
Datasource targets SakennyDB.
Datasource uses the dedicated grafana_reader login.
Dashboard loads SQL Server overview panels.
Dashboard reads security, session, database state, index, log space, and table data.
msdb permission issue for sysjobhistory was fixed with scoped SELECT grants.
```

Evidence:

```text
docs/evidence/grafana-sql-dashboard-overview.png
docs/evidence/grafana-sql-dashboard-security-monitoring.png
docs/evidence/grafana-sql-dashboard-index-health.png
```

Expected local limitations:

```text
Some panels show No data on SQL Server Express or a small local database.
SQL Server Agent job panels may show No data when no SQL Agent jobs exist.
Backup history panels may show No data until backups are created.
Slow query panels may show No data until enough workload is generated.
```

## Troubleshooting Notes

Connection refused:

```text
SQL Server is not listening on TCP 1433, the service is stopped, or Docker cannot reach the host.
Check SQL Server Configuration Manager, restart SQL Server, and verify Test-NetConnection localhost -Port 1433.
```

Login failed:

```text
SQL Server Authentication is disabled, the login password is wrong, or the login is not mapped to the database.
Enable mixed authentication, reset the login password, and create the database user mapping.
```

SELECT permission denied:

```text
The dashboard query is reading a DMV or msdb object that grafana_reader cannot access.
Grant the smallest required read permission instead of making grafana_reader sysadmin.
```

No data:

```text
The panel query succeeded, but the local database does not currently have matching workload, jobs, backups, or history.
This is normal for a small development database.
```

## Attribution

The dashboard JSON was imported and adapted for this Sakenny lab from:

```text
https://github.com/czantoine/microsoft-sql-server-with-grafana
```

That project is MIT-licensed and provides a Microsoft SQL Server Grafana dashboard based on native T-SQL DMVs. The local Sakenny changes are the datasource provisioning, Docker Compose wiring, environment handling, dashboard export into this repo, SQL Server least-privilege setup notes, and validation evidence.

## Next QA and DevSecOps Use

Use this dashboard while running future Postman/Newman and SQL Server tests:

```text
Run API smoke tests.
Watch SQL sessions and connections.
Generate property listing/filter workload.
Capture baseline query and database health screenshots.
Document before/after SQL tuning results.
```
