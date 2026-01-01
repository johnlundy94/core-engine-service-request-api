# CoreEngine API Contract: ServiceRequests (v1)

## Purpose

A **ServiceRequest** is the universal, client-submitted intake object for CoreEngine.
It represents a customer requesting service.

## Versioning

All endpoints are versioned under `/v1`.

---

## Resource

**ServiceRequest**

### Server-managed fields

- `serviceRequestId` (string)
- `createdAt` (ISO-8601 UTC string)
- `status` (string, default `"new"`)

---

## 1) Create ServiceRequest (public)

### Endpoint

`POST /v1/service-requests`

### Headers

- `Content-Type: application/json`
- Optional (recommended): `Idempotency-Key: <uuid>`

### Request Body: ServiceRequestCreateRequest

```json
{
  "customer": {
    "name": "Jane Doe",
    "email": "jane@email.com",
    "phone": "+1-123-456-7890"
  },
  "location": {
    "addressLine1": "123 Main St",
    "addressLine2": "Apt Number",
    "city": "City",
    "state": "State",
    "postalCode": "00000"
  },
  "service": {
    "budget": "1000-2500",
    "description": "This is the service description of the requested service"
  },
  "metadata": {
    "source": "client_web",
    "industryPack": "industry_pack_name"
  }
}
```

### Field rules (v1)

Required:

- `customer.name`
- `customer.email`
- `service.description`

Optional:

- `customer.phone`
- all `location.*`
- `service.budget`
- `metadata.source` (if omitted, server may default to `"client_web"`)
- `metadata.industryPack`

### Response 201: ServiceRequestCreateResponse

```json
{
  "serviceRequestId": "sr_01HQ9QZ7J2K6K8V8ZC1Y3M7T6R",
  "createdAt": "2026-01-01T16:22:11Z",
  "status": "new"
}
```

## Error Format (all REST endpoints)

### Response 4xx/5xx

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": {
      "field": "customer.email"
    }
  }
}
```

### Common status codes

- `400` Validation error (missing/invalid fields)
- `429` Rate limited
- `500` Unexpected server error

## CORS (required)

The API must allow:

- Local dev origin (example): `http://localhost:3000`
- Production client UI origin (to be configured per deployment)
