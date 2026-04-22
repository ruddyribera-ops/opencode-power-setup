---
name: code-review
description: Code review checklist for security, performance, and maintainability
---

# Code Review Checklist

## Security (check first)
- [ ] No hardcoded secrets, API keys, or passwords
- [ ] All user inputs validated and sanitized
- [ ] SQL queries use parameterized statements (no string concatenation)
- [ ] Authentication checked on all protected routes
- [ ] Sensitive data not logged or exposed in responses

## Logic & Correctness
- [ ] Edge cases handled (null, empty, zero, overflow)
- [ ] Error paths handled (not just happy path)
- [ ] No silent failures (errors caught but not handled)
- [ ] Async operations properly awaited

## Performance
- [ ] No N+1 database queries (use joins or batch queries)
- [ ] No expensive operations inside loops
- [ ] Large data sets paginated
- [ ] Caches used where appropriate

## Maintainability
- [ ] Functions do one thing (single responsibility)
- [ ] Variable/function names are descriptive
- [ ] Complex logic has a comment explaining WHY
- [ ] No dead code or commented-out blocks
- [ ] No magic numbers (use named constants)

## Tests
- [ ] New functionality has corresponding tests
- [ ] Edge cases tested
- [ ] Tests have clear names that describe behavior

## Review Tone
- Be specific: "This query runs on every render" not "This is slow"
- Explain why: "This could cause a race condition because..."
- Offer solutions: "Consider using useCallback here to memoize this"
- Distinguish: must-fix vs nice-to-have

## Anti-Patterns (Common Code Smells)

### ❌ Exception Silencing
```python
# BAD — silently swallows errors, makes debugging impossible
try:
    result = risky_operation()
except:
    pass  # Quietly fails, hard to diagnose

# GOOD — log or re-raise with context
try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f"Failed to do X: {e}", exc_info=True)
    raise
```

### ❌ Type Checking at Runtime Instead of Development
```python
# BAD — catches bugs in production, not development
def process(data):
    if not isinstance(data, dict):
        raise TypeError("Expected dict")
    return data['key']

# GOOD — types caught during development/CI
def process(data: dict) -> str:
    return data['key']
    # mypy/pyright will catch type errors at lint time
```

### ❌ Magic Numbers / Strings
```python
# BAD — what is 1000? What is 'ACTIVE'?
if user.status == 'ACTIVE' and user.age > 65:
    MAX_AMOUNT = 1000

# GOOD — named constants
STATUS_ACTIVE = 'ACTIVE'
MIN_RETIREMENT_AGE = 65
MAX_WITHDRAWAL_FOR_SENIORS = 1000

if user.status == STATUS_ACTIVE and user.age > MIN_RETIREMENT_AGE:
    max_amount = MAX_WITHDRAWAL_FOR_SENIORS
```

### ❌ Premature Optimization
```python
# BAD — complex code that doesn't solve the actual bottleneck
def process_users(users):
    cache = {}
    return [cache.get(u.id) or compute_complex_value(u) for u in users]

# GOOD — profile first, optimize proven bottlenecks
def process_users(users):
    return [compute_complex_value(u) for u in users]
    # If this is slow, measure WHICH part. Cache only what matters.
```

### ❌ Incomplete Error Messages
```python
# BAD — what failed?
raise Exception("Error")

# GOOD — specific, actionable error
raise ValueError(f"Expected user.age to be int, got {type(age).__name__}")
```

## Common Mistakes by Domain

### Database
- **Missing indexes** on frequently queried columns
- **N+1 queries** — fetching users then their orders in a loop (use JOIN)
- **String concatenation in SQL** — exposes to injection (use parameterized statements)

### API
- **Inconsistent error codes** — 404 for missing user, 400 for missing email (pick one per error type)
- **No rate limiting** — exposes to DoS
- **Secrets in responses** — returning full password hash or API key in JSON

### Frontend (JS/React)
- **Missing key prop in lists** — causes re-renders, lost state
- **Creating objects in render** — new object every render, breaks memoization
- **Direct DOM manipulation** — mixing React and vanilla JS causes sync bugs

### Python
- **Blocking I/O in async code** — `requests.get()` instead of `httpx` in async function
- **Shared mutable defaults** → `def func(items=[])` then appending modifies the default
- **Missing `__all__`** in modules → unclear public API