---
name: python-patterns
description: Modern Python 3.10+ patterns, type hints, FastAPI, Pydantic, and async best practices
---

# Python Modern Patterns

## Type Hints (Python 3.10+)

```python
# Use built-in types (no need for typing.List, typing.Dict in 3.10+)
def process_items(items: list[str], config: dict[str, int]) -> bool:
    ...

# Union types with | operator
def fetch(url: str, timeout: int | None = None) -> str | None:
    ...

# TypeAlias for complex types
type UserId = int
type UserMap = dict[UserId, "User"]
```

## Dataclasses (Structured Data)

```python
from dataclasses import dataclass, field

@dataclass
class User:
    id: int
    name: str
    email: str
    roles: list[str] = field(default_factory=list)
    active: bool = True

# Immutable (frozen)
@dataclass(frozen=True)
class Config:
    host: str
    port: int = 8000
    debug: bool = False
```

## Pydantic Models (Validation + Serialization)

```python
from pydantic import BaseModel, Field, field_validator

class CreateUserRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: str
    age: int = Field(ge=0, le=150)

    @field_validator("email")
    @classmethod
    def validate_email(cls, v: str) -> str:
        if "@" not in v:
            raise ValueError("Invalid email")
        return v.lower()

class UserResponse(BaseModel):
    id: int
    name: str
    email: str

    model_config = {"from_attributes": True}  # ORM mode
```

## FastAPI Patterns

```python
from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="My API")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Route with validation
@app.get("/users/{user_id}")
async def get_user(user_id: int) -> UserResponse:
    user = await db.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse.model_validate(user)

# Query params with defaults
@app.get("/users")
async def list_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    active: bool = True,
) -> list[UserResponse]:
    return await db.list_users(skip=skip, limit=limit, active=active)

# Dependency injection
async def get_db():
    db = Database()
    try:
        yield db
    finally:
        await db.close()

@app.post("/users")
async def create_user(
    data: CreateUserRequest,
    db: Database = Depends(get_db),
) -> UserResponse:
    return await db.create_user(data)
```

## Async/Await Patterns

```python
import asyncio
import httpx

# Parallel async calls
async def fetch_all(urls: list[str]) -> list[str]:
    async with httpx.AsyncClient() as client:
        tasks = [client.get(url) for url in urls]
        responses = await asyncio.gather(*tasks, return_exceptions=True)
        return [
            r.text if isinstance(r, httpx.Response) else str(r)
            for r in responses
        ]

# Async context manager
class AsyncDatabase:
    async def __aenter__(self):
        self.conn = await create_connection()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.conn.close()

# Timeout wrapper
async def with_timeout(coro, seconds: float):
    try:
        return await asyncio.wait_for(coro, timeout=seconds)
    except asyncio.TimeoutError:
        raise TimeoutError(f"Operation timed out after {seconds}s")
```

## Error Handling

```python
# Custom exceptions hierarchy
class AppError(Exception):
    def __init__(self, message: str, code: str = "UNKNOWN"):
        self.message = message
        self.code = code

class NotFoundError(AppError):
    def __init__(self, resource: str, id: int):
        super().__init__(f"{resource} {id} not found", code="NOT_FOUND")

class ValidationError(AppError):
    def __init__(self, field: str, reason: str):
        super().__init__(f"Invalid {field}: {reason}", code="VALIDATION")

# Result pattern (like Rust)
from dataclasses import dataclass
from typing import Generic, TypeVar

T = TypeVar("T")

@dataclass
class Result(Generic[T]):
    value: T | None = None
    error: str | None = None

    @property
    def ok(self) -> bool:
        return self.error is None

def divide(a: float, b: float) -> Result[float]:
    if b == 0:
        return Result(error="Division by zero")
    return Result(value=a / b)
```

## List/Dict Comprehensions

```python
# Filter and transform
active_names = [u.name for u in users if u.active]

# Dict from list
users_by_id = {u.id: u for u in users}

# Group by (using defaultdict)
from collections import defaultdict
by_role: dict[str, list[User]] = defaultdict(list)
for user in users:
    by_role[user.role].append(user)

# Walrus operator (:=) for filter + transform
results = [
    processed
    for item in items
    if (processed := expensive_transform(item)) is not None
]
```

## Context Managers

```python
from contextlib import contextmanager, asynccontextmanager

@contextmanager
def timer(label: str):
    import time
    start = time.perf_counter()
    yield
    elapsed = time.perf_counter() - start
    print(f"{label}: {elapsed:.2f}s")

# Usage
with timer("data processing"):
    process_data()

@asynccontextmanager
async def managed_transaction(db):
    tx = await db.begin()
    try:
        yield tx
        await tx.commit()
    except Exception:
        await tx.rollback()
        raise
```

## Environment & Config

```python
import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False
    port: int = 8000

    model_config = {"env_file": ".env"}

# Usage
settings = Settings()  # Auto-loads from .env and environment
```

## Decorators

```python
import functools
import time

def retry(max_attempts: int = 3, delay: float = 1.0):
    def decorator(func):
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return await func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    await asyncio.sleep(delay * (2 ** attempt))
        return wrapper
    return decorator

@retry(max_attempts=3, delay=0.5)
async def fetch_data(url: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        response.raise_for_status()
        return response.json()
```

## Anti-Patterns (What NOT to Do)

### ❌ Global variables instead of Pydantic settings
```python
# BAD — config is mutable and scattered
DEBUG = True
DATABASE_URL = "postgresql://..."

# GOOD — config is centralized and type-safe
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    debug: bool = True
    database_url: str
    
    model_config = {"env_file": ".env"}

settings = Settings()
```

### ❌ Mixing async/sync without clear boundaries
```python
# BAD — confusing mix, will hang
async def fetch():
    result = requests.get(url)  # BLOCKING! Will freeze the event loop
    return result

# GOOD — keep async pure or accept sync
async def fetch():
    async with httpx.AsyncClient() as client:
        result = await client.get(url)  # Non-blocking
    return result
```

### ❌ Unbounded list comprehensions on large data
```python
# BAD — loads entire dataset into memory
all_users = [u for u in query_all_users_from_db()]

# GOOD — iterate with yield or pagination
def users_iter():
    for user in db.users.paginate(limit=100):
        yield user
```

### ❌ `Optional[X]` when field is truly required
```python
# BAD — allows None but means to forbid it
class User(BaseModel):
    email: Optional[str] = None  # Is email optional or required?

# GOOD — explicit intent
class User(BaseModel):
    email: str  # Required
    middle_name: str | None = None  # Optional
```

## Pydantic v2 Migration (from v1)

**Common breaking changes:**
- `validator` → `field_validator` (change `@validator` decorator)
- `Config` nested class → `model_config` dictionary
- `.dict()` → `.model_dump()`
- `.json()` → `.model_dump_json()`
- `orm_mode` → `from_attributes` in `model_config`
- `create_model()` signature changed
- `parse_obj()` → use constructor directly or `.model_validate()`

**Example migration:**
```python
# v1
class User(BaseModel):
    email: str
    
    @validator('email')
    def validate_email(cls, v):
        return v.lower()
    
    class Config:
        orm_mode = True

# v2
class User(BaseModel):
    email: str
    
    @field_validator('email')
    @classmethod
    def validate_email(cls, v):
        return v.lower()
    
    model_config = {"from_attributes": True}
```

## Async Gotchas

- **Never use `time.sleep()` in async code** → blocks event loop. Use `await asyncio.sleep()` instead.
- **Gather exceptions:** `asyncio.gather(*tasks, return_exceptions=True)` catches errors, allowing other tasks to finish.
- **Timeout:** Always set timeouts on external calls (`asyncio.wait_for(coro, timeout=5)`) to avoid hanging forever.
- **Connection pools:** Reuse async clients (`async with httpx.AsyncClient() as client`) — don't create new ones per request.

## Learned from PRIA (Streamlit)

- **Import heavy libs in functions, not at top level** → Streamlit re-runs entire script on every interaction. Lazy imports + `@st.cache_resource` keep startup < 3s.
- **Use `st.session_state` for persistence** → values in local variables are reset on every rerun.
- **Async in Streamlit:** Call async funcs with `asyncio.run()` or use background threads carefully (Streamlit doesn't naturally await).
- **Pydantic models for form data** → validate user input with Pydantic before saving to database.
- **Type hints everywhere** → PRIA backend is FastAPI + Streamlit frontend; consistent types prevent bugs at the boundary.
