# API Test Runbook

This runbook documents the manual Swagger/Postman flow used to validate the Sakenny backend. It is written so the same flow can later be converted into a Postman collection, Newman test run, or automated integration test suite.

## Base URL

Use HTTPS during local testing:

```text
https://localhost:7279
```

Swagger:

```text
https://localhost:7279/swagger/index.html
```

## Swagger Authorization Rule

When using Swagger's `Authorize` button, paste only the raw JWT if the generated curl already adds `Authorization: Bearer`.

Correct:

```text
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Incorrect:

```text
Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

If Swagger receives `Bearer <token>`, it may send:

```http
Authorization: Bearer Bearer <token>
```

That causes `401 invalid_token`.

## Token Matrix

```text
Admin token:
  Use for Dashboard endpoints and user role conversion.

Host token:
  Use for /AddProperty, /UpdateProperty/{id}, and /owned-properties.

No token:
  Public property listing, property detail, and property filtering.
```

After converting a user to Host, log in again as that user. The old JWT still has the old role claim.

## 1. Register User

```http
POST /register
Content-Type: application/json
```

```json
{
  "firstName": "Juan",
  "lastName": "Test",
  "email": "juan@test.com",
  "password": "Password@123",
  "phoneNumber": "01012345678"
}
```

Expected result:

```text
200 OK
Account Created Successfully
```

SQL check:

```sql
SELECT Id, UserType, UserName, Email, FirstName, LastName
FROM AspNetUsers;
```

## 2. Login User

```http
POST /login
Content-Type: application/json
```

```json
{
  "email": "juan@test.com",
  "password": "Password@123",
  "rememberMe": false
}
```

Expected result:

```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "accessTokenExpiry": "...",
  "refreshTokenExpiry": "..."
}
```

## 3. Register Admin

```http
POST /AdminRegister
Content-Type: application/json
```

```json
{
  "username": "admin",
  "email": "admin@test.com",
  "password": "Admin@123"
}
```

## 4. Login Admin

```http
POST /AdminLogin
Content-Type: application/json
```

```json
{
  "email": "admin@test.com",
  "password": "Admin@123",
  "rememberMe": false
}
```

Use this token for admin-only actions.

## 5. Convert User To Host

Use admin token.

```http
POST /api/User/ConvertToHost/{userId}
```

Example:

```text
POST /api/User/ConvertToHost/867e4a0b-880f-42ee-8239-2f3eab6225ed
```

SQL check:

```sql
SELECT u.Id, u.Email, r.Name AS RoleName
FROM AspNetUsers u
JOIN AspNetUserRoles ur ON u.Id = ur.UserId
JOIN AspNetRoles r ON ur.RoleId = r.Id;
```

Expected:

```text
juan@test.com | Host
```

Then log in again as `juan@test.com` and use the new Host token.

## 6. Create Property Type

```http
POST /api/Type
Content-Type: application/json
```

```json
{
  "name": "Apartment"
}
```

SQL check:

```sql
SELECT * FROM PropertyTypes;
```

## 7. Create Services

`POST /api/Services` should accept both `name` and `icon`.

Use admin token after the Admin-only endpoint protection is applied.

```http
POST /api/Services
Content-Type: application/json
```

```json
{
  "name": "Sauna",
  "icon": "sauna"
}
```

Expected:

```text
200 OK
```

SQL check:

```sql
SELECT * FROM Services;
```

Earlier investigation used this temporary SQL workaround before the API contract was fixed:

```sql
INSERT INTO Services (Name, Icon, IsDeleted)
VALUES
('Wifi', 'wifi', 0),
('Parking', 'parking', 0),
('Air Conditioning', 'air-conditioning', 0);
```

## 8. Add Property

Use Host token.

```http
POST /AddProperty
Content-Type: multipart/form-data
```

Exact sample values:

```text
Title: Sunny Cairo Apartment
Description: Spacious furnished apartment with wifi parking and air conditioning for backend testing
PropertyTypeId: 1
Country: Egypt
City: Cairo
District: Nasr City
BuildingNo: 20
Level: 3
FlatNo: 8
Longitude: 31.2357
Latitude: 30.0444
RoomCount: 2
BathroomCount: 1
Space: 80
Price: 1500
PeopleCapacity: 4
mainImage: choose any .png or .jpg
images: choose any .png or .jpg
ServiceIds: 5
ServiceIds: 6
ServiceIds: 7
```

Expected tables:

```sql
SELECT * FROM Properties;
SELECT * FROM Images;
SELECT * FROM PropertyPermits;
SELECT * FROM propertySnapshots;
SELECT * FROM PropertyServices;
```

Expected relationship:

```text
Property 2 -> Service 5
Property 2 -> Service 6
Property 2 -> Service 7
```

## 9. Approve Property

Use admin token.

```http
PUT /api/Dashboard/pendingrequests/{id}/approve
```

Example:

```text
PUT /api/Dashboard/pendingrequests/2/approve
```

SQL check:

```sql
SELECT Id, Title, Status FROM Properties;
SELECT id, PropertyID, status, AdminID FROM PropertyPermits;
```

Expected property status:

```text
Status = 1
```

## 10. Public Property Listing

No token needed.

```http
GET /api/Property/all
```

Expected:

```text
Approved properties with property type names, image URLs, reviews count, and service names.
```

## 11. Public Property Detail

No token needed.

```http
GET /api/Property/2
```

## 12. Property Filter

No token needed.

```http
POST /api/Property/filter
Content-Type: application/json
```

```json
{
  "propertyTypeIds": [1],
  "country": "Egypt",
  "city": "Cairo",
  "district": "Nasr City",
  "serviceIds": [5, 6],
  "minPeople": 2,
  "minSpace": 70,
  "minPrice": 1000,
  "maxPrice": 2000,
  "orderBy": "price_asc"
}
```

Expected:

```text
Property 2 should be returned because it matches the location, price, space, capacity, type, and service filters.
```

## 13. Host-Owned Properties

Use Host token.

Authenticated host endpoint:

```http
GET /owned-properties
```

Public owner lookup by user ID:

```http
GET /owned-properties/{userId}
```

Important: `{userId}` is the Identity user GUID, not the property ID.

## 14. Admin Dashboard

Use admin token.

```http
GET /api/Dashboard/stats
GET /api/Dashboard/revenue
GET /api/Dashboard/pendingrequests
GET /api/Dashboard/salesbreakdown
GET /api/Dashboard/mapmarkers
GET /api/Dashboard/topproperties
GET /api/Dashboard/recenttransactions
```

## 15. Authorization Regression Matrix

These checks validate that lookup reads stay public while mutations require Admin.

Services:

```text
No token   + GET  /api/Services -> 200
No token   + POST /api/Services -> 401
Host token + POST /api/Services -> 403
Admin token + POST /api/Services -> 200
```

Types:

```text
No token   + GET  /api/Type -> 200
No token   + POST /api/Type -> 401
Host token + POST /api/Type -> 403
Admin token + POST /api/Type -> 200
```

## Routes To Watch

Some routes are absolute routes and are not under their controller prefix:

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

This is an improvement candidate because route consistency matters for maintainability and API consumer experience.
