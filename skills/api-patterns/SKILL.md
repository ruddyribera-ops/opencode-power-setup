---
name: api-patterns
description: REST API design patterns, error handling, and response format standards
---

# API Patterns

## Response Format (Consistent JSON)
Success:
```json
{ "data": { ... }, "meta": { "timestamp": "..." } }
```
Error:
```json
{ "error": { "code": "NOT_FOUND", "message": "User not found", "field": "userId" } }
```

## HTTP Status Codes
- 200 OK — successful GET, PUT
- 201 Created — successful POST
- 204 No Content — successful DELETE
- 400 Bad Request — invalid input (include error.field)
- 401 Unauthorized — not authenticated
- 403 Forbidden — authenticated but not permitted
- 404 Not Found — resource does not exist
- 409 Conflict — resource already exists
- 422 Unprocessable Entity — validation failed
- 500 Internal Server Error — unexpected server failure

## Input Validation
- Validate at the route/controller level before business logic
- Return 400 with specific field errors
- Never trust client input

## Authentication
- Use Authorization header: `Bearer <token>`
- Validate token on every protected route via middleware
- Never put tokens in URLs

## Error Handling
- Catch all async errors with try/catch or error middleware
- Log errors server-side with context (user, endpoint, timestamp)
- Never expose stack traces to clients in production

## Anti-Patterns (What NOT to Do)

### ❌ Changing API Response Format Without Versioning
```json
// v1.0 — deployed in production
{ "user": { "id": 1, "name": "Alice" } }

// v1.1 — oops, breaks all clients
{ "data": { "user": { "id": 1, "name": "Alice" } } }
```

**FIX:** Use API versioning (`/api/v1/users` vs `/api/v2/users`) or add `Accept-Version` header.

### ❌ Storing Sensitive Data in Error Messages
```python
# BAD — leaks internal details
if not user:
    raise HTTPException(404, detail=f"User {user_id} not found in table users_prod")

# GOOD — generic error, internal log separate
logger.info(f"User lookup failed: user_id={user_id}, table=users_prod")
raise HTTPException(404, detail="User not found")
```

### ❌ No Rate Limiting
```python
# BAD — exposed to brute force, DoS
@app.post("/auth/login")
async def login(email: str, password: str):
    ...

# GOOD — rate limit by IP or user
@limiter.limit("5/minute")  # 5 attempts per minute
@app.post("/auth/login")
async def login(email: str, password: str):
    ...
```

### ❌ Ignoring Async/Await in Error Handlers
```python
# BAD — error handler blocks, API freezes
try:
    result = await fetch_data()
except Exception:
    write_to_file(error_log)  # BLOCKING!

# GOOD — non-blocking error handling
try:
    result = await fetch_data()
except Exception:
    asyncio.create_task(log_error_async(error_log))
```

## API Versioning Tradeoffs

| Strategy | Pros | Cons |
|---|---|---|
| **URL path** (`/v1/users` vs `/v2/users`) | Clear, easy to test | Code duplication |
| **Query param** (`GET /users?api_version=2`) | One endpoint | Easy to miss version param |
| **Header** (`Accept-Version: 2`) | Clean, hidden | Client must know to set it |
| **No versioning, only add fields** | Minimal code | Breaking changes hard to avoid |

**Recommendation:** Use URL versioning for major breaks. Deprecate old endpoints gradually (6+ months notice).