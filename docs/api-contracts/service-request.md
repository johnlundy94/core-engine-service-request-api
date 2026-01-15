# CoreEngine API Contract: service-requests (v1)

## Purpose

A **ServiceRequest** is the universal, client-submitted intake object for CoreEngine.
It represents a customer requesting service. Industry packs may add additional fields and UI, but this contract remains industry-neutral.

## Versioning

All endpoints are versioned under `/v1`.

---

## Resource

**ServiceRequest**

### Server-managed fields

- `serviceRequestId` (string)
- `createdAt` (ISO-8601 UTC string)
- `status` (string, default `"new"`)
- Soft delete fields (set when deleted):
  - `deletedAt` (ISO-8601 UTC string)
  - `purgeAt` (ISO-8601 UTC string, TTL-enabled attribute)

### Status values (v1)

- `"new"`
- `"deleted"`

---

## Idempotency (required for create)

Create must be **exactly-once** under real-world retries (double submit, timeouts, mobile reconnects).
A unique `serviceRequestId` alone does not prevent duplicates if the first write succeeded but the client never received the response.

### Rule

- Header `Idempotency-Key` is **required** on create.
- Idempotency key scope: `(tenantId, Idempotency-Key)`
- If the same key is reused:
  - Same request body: return the original success response, do not create a second record
  - Different request body: return `409 Conflict`
- Idempotency record expiration: TTL on `expiresAt` (default 24 hours)

---

## 1) Create ServiceRequest (public)

### Endpoint

`POST /v1/service-requests`

### Headers

- `Content-Type: application/json`
- `Idempotency-Key: <uuid>` (required)

### Request Body: ServiceRequestCreateRequest

```json
{
  "customer": {
    "name": "Jane Doe",
    "phone": "+13035551212",
    "email": "jane@email.com"
  },
  "serviceLocation": {
    "address1": "123 Main St",
    "address2": "Unit B",
    "city": "Denver",
    "state": "CO",
    "postalCode": "80202",
    "country": "US"
  },
  "service": {
    "description": "This is the service description of the requested service",
    "budget": "1000-2500"
  },
  "metadata": {
    "source": "client-web",
    "industryPack": "industry-pack-name"
  }
}
```

### Field rules (v1)

Required:

- `customer.name`
- `customer.phone`
- `customer.email`
- `service.description`
- `serviceLocation.address1`
- `serviceLocation.city`
- `serviceLocation.state`
- `serviceLocation.postalCode`

Supported (optional):

- `serviceLocation.address2`
- `serviceLocation.country` (if omitted, server may default to `"US"`)
- `service.budget`
- `metadata.source` (if omitted, server may default to `"client-web"`)
- `metadata.industryPack`

Phone format guidance:

- Prefer E.164 format (example: `+13035551212`)

### Response 201: ServiceRequestCreateResponse (minimal)

```json
{
  "serviceRequestId": "sr_01HQ9QZ7J2K6K8V8ZC1Y3M7T6R",
  "createdAt": "2026-01-01T16:22:11Z",
  "status": "new"
}
```

---

## 2) Delete ServiceRequest (admin)

### Endpoint

`DELETE /v1/service-requests/{serviceRequestId}`

### Behavior (canonical): soft delete with retention

The server performs a soft delete:

- set `status = "deleted"`
- set `deletedAt = <now>`
- set `purgeAt = <now + retentionDays>` (TTL-enabled attribute)

Retention (v1 default): **90 days** (configurable later per tenant).

### Response

- `204 No Content` on success
- Repeated deletes are treated as success (DELETE is idempotent by behavior)

---

## Persistence expectation (DynamoDB item)

A ServiceRequest item stored in the service-requests table includes:

- keys + server-managed fields
- the submitted payload objects: `customer`, `service`, `serviceLocation`
- soft delete retention fields when deleted (`deletedAt`, `purgeAt`)

Example stored item shape:

```json
{
  "tenantId": "t_123",
  "serviceRequestId": "sr_01HQ9QZ7J2K6K8V8ZC1Y3M7T6R",
  "createdAt": "2026-01-01T16:22:11Z",
  "status": "new",
  "customer": {
    "name": "Jane Doe",
    "phone": "+13035551212",
    "email": "jane@email.com"
  },
  "serviceLocation": {
    "address1": "123 Main St",
    "address2": "Unit B",
    "city": "Denver",
    "state": "CO",
    "postalCode": "80202",
    "country": "US"
  },
  "service": {
    "description": "This is the service description of the requested service",
    "budget": "1000-2500"
  },
  "metadata": {
    "source": "client-web",
    "industryPack": "industry-pack-name"
  }
}
```

---

## WebSocket events (admin broadcast, minimal payload)

WebSocket is push-only for admin dashboard updates in v1.
The WebSocket payload is intentionally minimal and does not include full `customer/service/serviceLocation` fields.

### Event types

- `serviceRequest.created`
- `serviceRequest.deleted`

### Canonical envelope

```json
{
  "type": "serviceRequest.created",
  "data": {
    "serviceRequestId": "sr_01HQ9QZ7J2K6K8V8ZC1Y3M7T6R",
    "createdAt": "2026-01-01T16:22:11Z",
    "status": "new"
  }
}
```

Minimum payload rules:

- `serviceRequest.created`: `serviceRequestId`, `createdAt`, `status`
- `serviceRequest.deleted`: `serviceRequestId`

---

## Error Format (all REST endpoints)

### Response 4xx/5xx

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Phone is required",
    "details": {
      "field": "customer.phone"
    }
  }
}
```

### Common status codes

- `400` Validation error (missing/invalid fields)
- `409` Idempotency key reused with a different request body
- `429` Rate limited
- `500` Unexpected server error

---

## CORS (required)

The API must allow:

- Local dev origin (example): `http://localhost:3000`
- Production client UI origin (to be configured per deployment)
