# SQL Server Test Notes

This document captures the SQL Server checks used during backend validation and the future database performance work planned for this project.

## Current Local Database

```text
Server: .\SQLEXPRESS
Database: SakennyDB
Authentication: Windows integrated security
Monitoring login: grafana_reader
```

## Core Tables Observed

Identity tables:

```text
AspNetUsers
AspNetRoles
AspNetUserRoles
AspNetUserClaims
AspNetUserLogins
AspNetUserTokens
AspNetRoleClaims
```

Domain tables:

```text
PropertyTypes
Services
Properties
Images
PropertyPermits
propertySnapshots
PropertyServices
PropertySnapshotService
Rentings
Reviews
DummyTables
__EFMigrationsHistory
```

## Validation Queries

Check roles:

```sql
SELECT * FROM AspNetRoles;
```

Check users and role assignments:

```sql
SELECT u.Id, u.Email, r.Name AS RoleName
FROM AspNetUsers u
JOIN AspNetUserRoles ur ON u.Id = ur.UserId
JOIN AspNetRoles r ON ur.RoleId = r.Id;
```

Check lookup data:

```sql
SELECT * FROM PropertyTypes;
SELECT * FROM Services;
```

Check property creation:

```sql
SELECT * FROM Properties;
SELECT * FROM Images;
SELECT * FROM PropertyPermits;
SELECT * FROM propertySnapshots;
SELECT * FROM PropertyServices;
```

Check property and service relationship:

```sql
SELECT
  p.Id AS PropertyId,
  p.Title,
  s.Id AS ServiceId,
  s.Name AS ServiceName
FROM Properties p
JOIN PropertyServices ps ON p.Id = ps.PropertiesId
JOIN Services s ON ps.ServicesId = s.Id
ORDER BY p.Id, s.Id;
```

Check approved properties:

```sql
SELECT Id, Title, Status, IsDeleted, UserId
FROM Properties
ORDER BY Id;
```

## Manual Seed Used During Early Validation

The first validation pass found that the `Services` API could not create rows because the table required `Icon`, but the create DTO only accepted `Name`. This SQL was used as a temporary test-data workaround before the API contract was fixed:

```sql
INSERT INTO Services (Name, Icon, IsDeleted)
VALUES
('Wifi', 'wifi', 0),
('Parking', 'parking', 0),
('Air Conditioning', 'air-conditioning', 0);
```

Current state:

```text
POST /api/Services now accepts name and icon.
Admin authorization is required for Services and Type mutations.
The SQL seed remains useful only for quick local setup or emergency test-data repair.
```

## Grafana Monitoring Validation

The local SQL Server observability setup is documented in:

```text
docs/OBSERVABILITY_SQL_SERVER_GRAFANA.md
```

Validated monitoring behavior:

```text
Grafana connects to SQL Server through host.docker.internal:1433.
Dashboard queries read SakennyDB metadata, sessions, waits, log space, table sizes, indexes, and security counters.
grafana_reader uses read-only/scoped monitoring permissions.
msdb job history panels required object-level SELECT grants.
Some SQL Server Express panels show No data because the local database has no SQL Agent workload or backup history yet.
```

## Performance Baseline Plan

The database improvement phase should be evidence-driven. Do not add indexes or partitioning just because they sound advanced. Measure first.

Target queries:

```text
Property listing
Property filtering by location/type/service/price
Property details with images, type, services, and reviews
Host-owned property list
Admin dashboard stats
Rental date conflict checks
Revenue/dashboard aggregation
```

Metrics to capture:

```text
Duration
CPU time
Logical reads
Physical reads
Execution plan operators
Missing index hints
Waits
Blocking
Deadlocks
Query Store regressions
```

Suggested SQL Server tools:

```text
Actual Execution Plan
SET STATISTICS IO ON
SET STATISTICS TIME ON
Query Store
SQL Server Profiler or Extended Events
Activity Monitor
DMVs for missing indexes and waits
```

Example measurement format:

```text
Baseline:
Endpoint: POST /api/Property/filter
Rows in Properties: TBD
Rows in PropertyServices: TBD
Duration: TBD
Logical reads: TBD
Plan issue: TBD

Change:
Add measured index or query optimization.

After:
Duration: TBD
Logical reads: TBD
Result: TBD
```

## Candidate Indexes To Investigate Later

These are not final recommendations. They are hypotheses to test with real data and execution plans.

```sql
-- Filtering by common search fields
CREATE INDEX IX_Properties_Search
ON Properties (PropertyTypeId, Country, City, District, Price, Space, PeopleCapacity)
INCLUDE (Title, MainImageUrl, Status, IsDeleted);

-- Host-owned property lookup
CREATE INDEX IX_Properties_UserId_IsDeleted
ON Properties (UserId, IsDeleted);

-- Booking/date conflict checks
CREATE INDEX IX_Rentings_PropertyId_StartDate_EndDate
ON Rentings (PropertyId, StartDate, EndDate);

-- Reviews by property
CREATE INDEX IX_Reviews_PropertyId_IsDeleted
ON Reviews (PropertyId, IsDeleted)
INCLUDE (Rate);
```

Only apply indexes after measuring the baseline and confirming the query patterns.
