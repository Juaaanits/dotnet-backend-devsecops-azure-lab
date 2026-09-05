# Local Setup and Validation Report

Status: validated locally on 2026-09-05. First bug-fix validation also completed for authentication middleware, Services API creation, and Admin-only lookup mutations.

This document records the backend setup and manual validation completed for the Sakenny backend clone. The goal was to prove the API can run locally with SQL Server, Swagger, JWT authentication, and local Azure Blob emulation before starting bug fixes and automation work.

## Environment

- OS: Windows
- Runtime: .NET 8 target project, .NET SDK available locally
- Database: SQL Server Express using `.\SQLEXPRESS`
- Database name: `SakennyDB`
- API profile: `https`
- Swagger URL: `https://localhost:7279/swagger/index.html`
- HTTP URL also available: `http://localhost:5111`
- Local blob emulator: Azurite on `127.0.0.1:10000`

## Local Configuration

The application reads its SQL Server connection from:

```json
"ConnectionStrings": {
  "DefaultConnection": "data source = .\\SQLEXPRESS; initial catalog = SakennyDB ; integrated security = true ; TrustServerCertificate=True;"
}
```

The application reads local blob storage from:

```json
"AzureBlobStorage": {
  "ConnectionString": "UseDevelopmentStorage=true",
  "containerName": "images"
}
```

This means local testing requires SQL Server and Azurite. A real Azure Storage account is not required for local backend validation.

## Setup Commands

Run from the backend root:

```powershell
dotnet restore .\sakenny.sln
dotnet build .\sakenny.sln
```

Apply EF Core migrations:

```powershell
dotnet ef database update --project .\sakenny\sakenny.csproj --startup-project .\sakenny\sakenny.csproj
```

Start Azurite with Docker:

```powershell
docker run --rm -it `
  -p 10000:10000 `
  -p 10001:10001 `
  -p 10002:10002 `
  --name sakenny-azurite `
  mcr.microsoft.com/azure-storage/azurite
```

Start the API:

```powershell
dotnet run --project .\sakenny\sakenny.csproj --launch-profile https
```

## Database Validation

The database schema was created through EF Core migrations. The application also creates the Identity roles at startup.

Validated role rows:

```text
Host
Admin
User
```

Useful verification queries:

```sql
SELECT * FROM AspNetRoles;
SELECT * FROM AspNetUsers;
SELECT * FROM PropertyTypes;
SELECT * FROM Services;
SELECT * FROM Properties;
SELECT * FROM Images;
SELECT * FROM PropertyPermits;
SELECT * FROM propertySnapshots;
SELECT * FROM PropertyServices;
```

## Validated Manual Workflow

The following backend flow was tested successfully:

1. Applied EF Core migrations against SQL Server.
2. Started the API through the `.NET 8` project.
3. Started Azurite for local blob storage.
4. Verified startup role creation in `AspNetRoles`.
5. Registered a normal user through `/register`.
6. Registered an admin through `/AdminRegister`.
7. Logged in through `/login` and `/AdminLogin`.
8. Used Swagger JWT authorization.
9. Converted a user from `User` to `Host`.
10. Re-logged in as the host to get a fresh role-bearing JWT.
11. Created property types.
12. Initially worked around the service creation bug by inserting services directly in SQL Server.
13. Created properties through `/AddProperty` using `multipart/form-data`.
14. Verified image URLs persisted from Azurite.
15. Verified property-service relationships in `PropertyServices`.
16. Approved properties as admin.
17. Verified public property listing, details, and filtering.
18. Verified host-owned property endpoints.
19. Verified admin dashboard endpoints.
20. Validated `POST /api/Services` after adding the missing `Icon` API contract.
21. Validated Admin-only authorization for Type and Services mutation endpoints.

## Local Data Created During Validation

Sample property type:

```text
Id: 1
Name: Apartment
```

Sample services used during validation:

```text
Id: 5, Name: Wifi, Icon: wifi
Id: 6, Name: Parking, Icon: parking
Id: 7, Name: Air Conditioning, Icon: air-conditioning
Id: 9, Name: Pool, Icon: pool
Id: 10, Name: Sauna, Icon: sauna
```

The first services were inserted manually while investigating the API issue. Later validation confirmed that the API can create services with both `Name` and `Icon`.

Sample properties:

```text
Id: 1
Title: Test Apartment
Status: 1
Services: none
```

```text
Id: 2
Title: Sunny Cairo Apartment
Status: 1
Services: Wifi, Parking, Air Conditioning
```

Sample property-service links:

```text
Property 2 -> Service 5
Property 2 -> Service 6
Property 2 -> Service 7
```

## Important Findings

- The database is empty after migrations by design. Migrations create schema; they do not seed sample users, services, property types, or properties.
- Roles are created at application startup, not by migration seed data.
- Azurite must be running because `BlobService` creates the blob container when the dependent service is constructed.
- Swagger bearer authorization should receive the raw token only when Swagger already applies the `Bearer` scheme.
- Host/admin role changes require a fresh login because the JWT contains role claims at token creation time.
- Type and Services mutation endpoints now follow the expected authorization matrix: no token returns 401, Host token returns 403, and Admin token returns 200.
