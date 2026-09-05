# Known Issues and Fix Plan

This document records issues discovered during local validation. The intent is to convert manual debugging into a visible engineering backlog with impact, proposed fix, and validation criteria.

## Issue Summary

| ID | Priority | Area | Status | Finding |
| --- | --- | --- | --- | --- |
| BUG-001 | High | Authentication | Fixed locally | JWT authorization required `app.UseAuthentication()` before `app.UseAuthorization()`. |
| BUG-002 | High | Services API | Open | `POST /api/Services` fails because `Service.Icon` is required but `AddServiceDTO` does not accept `Icon`. |
| BUG-003 | Medium | Authorization | Open | Type and Services management endpoints are public but should likely be admin-only. |
| BUG-004 | Medium | Storage | Open | `BlobService` connects to Azurite during service construction, affecting unrelated requests. |
| BUG-005 | Medium | API Design | Open | Some routes are absolute and inconsistent with controller route prefixes. |
| BUG-006 | High | Secrets | Open | JWT key and external service settings are stored in appsettings. |
| BUG-007 | Low | EF Model | Open | EF logs warnings about required relationships with global query filters. |
| BUG-008 | Low | EF Model | Open | EF logs warnings about decimal precision on `PropertySnapshot`. |
| BUG-009 | Low | Code Quality | Open | Build warnings show possible null dereferences in dashboard logic. |

## BUG-001: Missing Authentication Middleware

Observed behavior:

```text
Protected endpoints returned 401 or did not resolve role claims correctly.
```

Root cause:

```csharp
app.UseAuthorization();
```

was present without authentication being executed first.

Fix:

```csharp
app.UseAuthentication();
app.UseAuthorization();
```

Validation:

```text
Admin token can call Dashboard endpoints.
Admin token can convert a user to Host.
Host token can call /AddProperty and /owned-properties.
Public endpoints remain accessible without a token.
```

Status:

```text
Fixed locally and validated through Swagger.
```

## BUG-002: Services API Cannot Create Valid Rows

Observed behavior:

```text
POST /api/Services returned 500 while saving entity changes.
```

Root cause:

```text
Services.Icon is required in the database/model, but AddServiceDTO only accepts Name.
```

Temporary workaround:

```sql
INSERT INTO Services (Name, Icon, IsDeleted)
VALUES
('Wifi', 'wifi', 0),
('Parking', 'parking', 0),
('Air Conditioning', 'air-conditioning', 0);
```

Preferred fix:

```text
Add Icon to AddServiceDTO and validate it.
Map Icon into Service during create/update.
Return a proper 400 response for invalid input instead of a generic 500.
```

Validation:

```text
POST /api/Services creates a service with Name and Icon.
GET /api/Services returns the new service.
/AddProperty can link ServiceIds created through the API.
PropertyServices contains the expected relationship rows.
```

## BUG-003: Lookup Management Endpoints Are Public

Observed behavior:

```text
POST /api/Type and POST /api/Services can be called without authentication.
```

Risk:

```text
Unauthenticated users can mutate lookup/reference data.
```

Proposed fix:

```text
Require Admin role for create/update/delete endpoints on TypeController and ServicesController.
Keep read endpoints public if needed by the frontend.
```

Validation:

```text
Anonymous POST/PUT/DELETE returns 401.
Host/User POST/PUT/DELETE returns 403.
Admin POST/PUT/DELETE returns 200.
GET remains accessible if public lookup reads are required.
```

## BUG-004: BlobService Constructor Has External Side Effect

Observed behavior:

```text
/register failed when Azurite was not running.
```

Root cause:

```text
UserController resolves UserService.
UserService resolves ImageService.
ImageService resolves BlobService.
BlobService constructor immediately creates the blob container.
```

Risk:

```text
Requests unrelated to image upload can fail because local blob storage is unavailable.
Startup and controller activation become coupled to external infrastructure.
```

Proposed fix:

```text
Move container creation to application startup health/setup or lazy initialization.
Avoid external network calls in constructors.
Only require blob storage when image endpoints or image upload flows are used.
```

Validation:

```text
/register works when Azurite is stopped.
Image upload returns a clear storage error when Azurite is stopped.
Image upload works when Azurite is running.
```

## BUG-005: Inconsistent Absolute Routes

Examples:

```text
/register
/login
/AdminRegister
/AdminLogin
/AddProperty
/UpdateProperty/{id}
/owned-properties
/owned-properties/{userId}
```

Risk:

```text
API consumers expect controller-based paths like /api/User/login or /api/Property/{id}.
Mixed route styles make Swagger and Postman collections harder to understand.
```

Proposed fix:

```text
Standardize routes under controller prefixes.
Keep backward-compatible aliases temporarily if needed.
Document breaking changes clearly.
```

Validation:

```text
Swagger paths are consistent.
Postman collection uses predictable resource naming.
Existing critical flows still pass.
```

## BUG-006: Secrets In Configuration

Observed behavior:

```text
JWT signing key and external integration placeholders are stored in appsettings.json.
```

Risk:

```text
Secrets can be committed or reused across environments.
```

Proposed fix:

```text
Use dotnet user-secrets for local development.
Use environment variables in Docker/CI.
Use Azure Key Vault for Azure deployment.
Rotate any real keys that were committed.
```

Validation:

```text
Application starts with user-secrets locally.
Application fails fast with clear error when required secrets are missing.
CI does not expose secret values in logs.
```

## BUG-007: Global Query Filter Relationship Warnings

Observed behavior:

```text
EF Core warns about required relationships where the required entity has a global query filter.
```

Risk:

```text
Soft-deleted required entities may cause unexpected missing related data.
```

Proposed fix:

```text
Review required/optional relationships involving soft-deletable entities.
Add matching query filters where appropriate.
Make navigations optional only when the domain allows it.
```

Validation:

```text
EF warning is removed.
Soft delete scenarios have explicit tests.
Property, permit, renting, and snapshot queries behave predictably.
```

## BUG-008: Decimal Precision Warnings

Observed behavior:

```text
EF Core warns that decimal properties on PropertySnapshot do not specify precision or SQL column type.
```

Risk:

```text
Latitude, longitude, and price values may be silently truncated.
```

Proposed fix:

```text
Configure precision for PropertySnapshot decimal fields.
Use the same precision as the active Property entity where appropriate.
```

Validation:

```text
EF warning is removed.
Inserted snapshot longitude, latitude, and price preserve expected precision.
```

## BUG-009: Nullable Warnings In Dashboard Logic

Observed behavior:

```text
Build output reports possible null dereferences in DashboardService.
```

Risk:

```text
Dashboard endpoints may fail when related entities are missing or optional data is null.
```

Proposed fix:

```text
Review each nullable warning.
Add null-safe projections and defaults.
Add tests for empty database, missing related data, and normal dashboard data.
```

Validation:

```text
Build warnings reduced.
Dashboard endpoints return stable responses for empty and populated databases.
```

## Execution Order

Recommended implementation order:

```text
1. BUG-002: Fix Services API so test data can be created through the API.
2. BUG-003: Protect lookup mutation endpoints.
3. BUG-004: Remove BlobService constructor side effect.
4. BUG-006: Move secrets out of appsettings.
5. BUG-005: Standardize route design.
6. BUG-007/008/009: Clean EF and nullable warnings with tests.
```

