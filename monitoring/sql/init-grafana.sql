USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'grafana_reader')
    CREATE LOGIN grafana_reader WITH PASSWORD = '$(GrafanaPassword)';
ELSE
    ALTER LOGIN grafana_reader WITH PASSWORD = '$(GrafanaPassword)';
GO
GRANT VIEW SERVER STATE TO grafana_reader;
GRANT VIEW ANY DATABASE TO grafana_reader;
GO
USE SakennyDB;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'grafana_reader')
    CREATE USER grafana_reader FOR LOGIN grafana_reader;
GO
ALTER ROLE db_datareader ADD MEMBER grafana_reader;
GRANT VIEW DATABASE STATE TO grafana_reader;
GO
USE msdb;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'grafana_reader')
    CREATE USER grafana_reader FOR LOGIN grafana_reader;
GO
GRANT SELECT ON dbo.sysjobhistory TO grafana_reader;
GRANT SELECT ON dbo.sysjobs TO grafana_reader;
GRANT SELECT ON dbo.sysjobactivity TO grafana_reader;
GRANT SELECT ON dbo.sysjobschedules TO grafana_reader;
GRANT SELECT ON dbo.sysschedules TO grafana_reader;
GO
