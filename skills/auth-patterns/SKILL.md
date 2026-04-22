---
name: auth-patterns
description: Password hashing, sessions, JWT, password change flows, and DB-type gotchas for auth flags
---

# Authentication Patterns

## TL;DR — Top 5 Rules (Read First, Always Apply)

1. **Passwords → bcrypt (cost ≥ 12) or argon2.** Never MD5, SHA, or plain text.
2. **Same error for "user not found" and "wrong password"** — always return "invalid credentials" to prevent email enumeration.
3. **JWT secret in env, ≥ 256 bits, `exp` claim always set.** Access tokens: 15–30 min. Refresh: 7–30 days.
4. **Session cookies need `HttpOnly`, `Secure`, `SameSite=Lax`.** Never store tokens in `localStorage`.
5. **Password change requires current password; password reset invalidates ALL sessions.**

**DB gotcha:** PostgreSQL rejects Python `True`/`False` in an INTEGER column (SQLite doesn't). Use `BOOLEAN` consistently or cast with `int(bool_value)`. See `database-patterns` → "SQLite ↔ PostgreSQL Type Drift".

---

Auth is high-stakes: get it wrong and users get locked out OR attackers get in. Start with proven libraries — never roll your own crypto.

## Password Hashing (Use bcrypt or argon2 — NEVER MD5/SHA1/plain)

### Python (bcrypt)
```python
import bcrypt

def hash_password(password: str) -> str:
    if not password:
        raise ValueError("password cannot be empty")
    # Cost factor 12 = ~250ms on modern hardware. Raise as hardware improves.
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12)).decode()

def verify_password(password: str, hashed: str) -> bool:
    if not password or not hashed:
        return False
    try:
        return bcrypt.checkpw(password.encode(), hashed.encode())
    except (ValueError, TypeError):
        return False  # malformed hash
```

### Node (bcrypt)
```javascript
import bcrypt from 'bcrypt';

export async function hashPassword(password) {
  if (!password) throw new Error('password cannot be empty');
  return bcrypt.hash(password, 12);
}

export async function verifyPassword(password, hashed) {
  if (!password || !hashed) return false;
  try {
    return await bcrypt.compare(password, hashed);
  } catch {
    return false;
  }
}
```

### ❌ Never do this
```python
import hashlib
# DON'T — fast hashes are crackable in minutes on modern GPUs
hashed = hashlib.md5(password.encode()).hexdigest()
hashed = hashlib.sha256(password.encode()).hexdigest()  # Also fast — attackers love this

# DON'T — plain text
db.save(user.email, password)

# DON'T — "custom" obfuscation
hashed = base64.encode(password[::-1])  # This is not hashing
```

## JWT (JSON Web Tokens) — for stateless APIs

### Python (PyJWT)
```python
import jwt
from datetime import datetime, timedelta, timezone

SECRET = os.environ["JWT_SECRET"]  # Load from env — never hardcode
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE = timedelta(minutes=30)

def create_access_token(user_id: int) -> str:
    payload = {
        "sub": str(user_id),
        "iat": datetime.now(timezone.utc),
        "exp": datetime.now(timezone.utc) + ACCESS_TOKEN_EXPIRE,
    }
    return jwt.encode(payload, SECRET, algorithm=ALGORITHM)

def decode_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, SECRET, algorithms=[ALGORITHM])
    except jwt.ExpiredSignatureError:
        return None  # Expired
    except jwt.InvalidTokenError:
        return None  # Tampered or malformed
```

### JWT rules
- **Short-lived access tokens** (15–30 min) + long-lived refresh tokens (7–30 days)
- **Secret ≥ 256 bits** and loaded from env, never committed
- **`exp` claim always set** — tokens without expiration are footguns
- **Include `sub`** (subject = user id) — never put passwords, SSNs, or PII in a JWT
- **Rotate the secret** if you suspect a leak (invalidates all existing tokens — that's the point)

## Session Persistence ("Remember Me")

For server-rendered apps (Streamlit, Flask templates), use a session cookie + server-side session store.

```python
# Streamlit example (sessions via st.session_state + DB-backed session token)
import secrets

def create_session(user_id: int, remember_me: bool) -> str:
    token = secrets.token_urlsafe(32)  # 256 bits of entropy — cryptographically secure
    expires_at = datetime.now(timezone.utc) + (
        timedelta(days=30) if remember_me else timedelta(hours=8)
    )
    db.execute(
        "INSERT INTO sessions (token, user_id, expires_at) VALUES (%s, %s, %s)",
        (token, user_id, expires_at),
    )
    return token

def validate_session(token: str) -> int | None:
    row = db.fetchone(
        "SELECT user_id FROM sessions WHERE token = %s AND expires_at > NOW()",
        (token,),
    )
    return row[0] if row else None
```

### Cookie flags that matter
- `HttpOnly` — blocks JS access (prevents XSS stealing the cookie)
- `Secure` — HTTPS only (prevents MITM on plain HTTP)
- `SameSite=Lax` (default) or `Strict` — CSRF protection
- Never store passwords, API keys, or JWTs in `localStorage` — `HttpOnly` cookies are safer

## Password Change Flow

A safe password change requires the CURRENT password — otherwise a session hijack turns into an account takeover.

```python
def change_password(user_id: int, current_pw: str, new_pw: str) -> bool:
    user = db.get_user(user_id)
    if not verify_password(current_pw, user.password_hash):
        raise PermissionError("current password is wrong")
    if len(new_pw) < 12:
        raise ValueError("new password must be at least 12 chars")
    if new_pw == current_pw:
        raise ValueError("new password must differ from current")

    new_hash = hash_password(new_pw)
    db.execute("UPDATE users SET password_hash = %s WHERE id = %s", (new_hash, user_id))

    # Invalidate all other sessions — user's current session stays, everything else logs out
    db.execute("DELETE FROM sessions WHERE user_id = %s AND token != %s", (user_id, current_session_token))
    return True
```

### After a password reset (forgot-password flow)
- Invalidate ALL sessions, including the current one — force re-login
- Send an email notification: "your password was changed at HH:MM from IP X" — gives users a chance to react to account compromise

## Password Reset (Forgot-Password Flow)

```python
def request_password_reset(email: str) -> None:
    user = db.get_user_by_email(email)
    # ALWAYS return the same response whether user exists or not (prevents email enumeration)
    if user:
        token = secrets.token_urlsafe(32)
        expires_at = datetime.now(timezone.utc) + timedelta(hours=1)
        db.execute(
            "INSERT INTO password_resets (token, user_id, expires_at) VALUES (%s, %s, %s)",
            (token, user.id, expires_at),
        )
        send_email(user.email, reset_link=f"https://app.example.com/reset?token={token}")
    # Same response either way:
    return {"message": "if that email exists, a reset link has been sent"}
```

## PostgreSQL Boolean Gotcha (Dev SQLite → Prod PG)

SQLite happily accepts `True`, `False`, `0`, `1`, `'true'` for the same boolean-ish column. PostgreSQL is strict.

```python
# Column declared INTEGER but assigned Python booleans:
user.must_change_password = True  # SQLite: stores 1. PostgreSQL: TypeError.

# FIX 1 — declare BOOLEAN consistently everywhere
# SQL: must_change_password BOOLEAN NOT NULL DEFAULT FALSE
# Python: user.must_change_password = True  ✓

# FIX 2 — cast explicitly when writing
cur.execute(
    "UPDATE users SET must_change_password = %s WHERE id = %s",
    (int(must_change), user_id),  # bool → int cast
)
```

See `database-patterns` → "SQLite ↔ PostgreSQL Type Drift" for the idempotent migration helper.

## Anti-Patterns

### ❌ Returning different HTTP codes for "user not found" vs "wrong password"
```python
# BAD — tells attacker which emails are registered
if not user:
    return 404
if not verify_password(pw, user.hash):
    return 401

# GOOD — same response either way
if not user or not verify_password(pw, user.hash):
    return 401, {"error": "invalid credentials"}
```

### ❌ Rate-limiting only the login endpoint
```python
# BAD — attacker hits /forgot-password 1000x/sec to enumerate emails
# GOOD — rate-limit ALL auth endpoints: login, register, forgot, reset, change
```

### ❌ Storing password hashes in logs
```python
# BAD — logs often leak to third-party aggregators
logger.info(f"user {user.email} logged in with hash {user.password_hash}")

# GOOD — never log secrets or hashes
logger.info(f"user {user.id} logged in")
```

### ❌ Letting users set passwords shorter than 12 chars
```python
# BAD — 8 chars is crackable in hours
if len(pw) < 8: raise ValueError

# GOOD — NIST 800-63B recommends min 8 but strong guidance is 12+
if len(pw) < 12: raise ValueError
```

## Auth Implementation Checklist

- [ ] Passwords hashed with bcrypt (cost ≥ 12) or argon2 — never MD5/SHA/plain
- [ ] All auth endpoints rate-limited (login, register, forgot, reset, change)
- [ ] Same response for "user not found" and "wrong password" (prevents enumeration)
- [ ] JWT secret loaded from env, ≥ 256 bits, never in git
- [ ] Tokens have `exp` claim (access: 15–30 min, refresh: 7–30 days)
- [ ] Session cookies: `HttpOnly`, `Secure`, `SameSite=Lax`/`Strict`
- [ ] Password change requires current password
- [ ] Password reset invalidates ALL sessions
- [ ] Password reset tokens expire within 1 hour
- [ ] No passwords, hashes, or tokens in logs
- [ ] DB column types consistent between dev and prod (BOOLEAN vs INTEGER gotcha)
