---
name: database-patterns
description: SQL/SQLite migration patterns, seed data, and query utilities
---

# Database Patterns

## SQLite / sql.js (Browser-compatible)

### Table Creation
```javascript
// Safe to run multiple times - won't recreate if exists
db.run(`CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)`);
```

### Column Migration
```javascript
// Add column if missing (idempotent)
try {
  db.run("ALTER TABLE users ADD COLUMN phone TEXT");
} catch (e) {
  // Column already exists - ignore
}
```

### Seed Data Pattern
```javascript
// Only seed when table is EMPTY
const count = db.exec("SELECT COUNT(*) FROM users")[0]?.values[0][0] || 0;
if (count === 0) {
  db.run('INSERT INTO users (name, email) VALUES (?, ?)', ['Admin', 'admin@example.com']);
  console.log('Seeded default users');
}
```

### Query Utilities
```javascript
// Get all rows
function getAll(sql, params = []) {
  const stmt = db.prepare(sql);
  if (params.length) stmt.bind(params);
  const results = [];
  while (stmt.step()) results.push(stmt.getAsObject());
  stmt.free();
  return results;
}

// Get single row
function getOne(sql, params = []) {
  return getAll(sql, params)[0] || null;
}
```

## PostgreSQL / MySQL Notes
- Use migration tools (knex, prisma, sequelize) for schema changes
- Never ALTER TABLE in production without backup
- Use connection pooling for high traffic

## SQLite ↔ PostgreSQL Type Drift (Common Dev→Prod Bug)

SQLite is permissive with types; PostgreSQL is strict. Same code that works in dev can break in prod.

### The booleans trap
```python
# SQLite: accepts 0/1, 'true'/'false', True/False interchangeably
# PostgreSQL: strict — column declared BOOLEAN rejects integers, column declared INTEGER rejects True/False

# Schema mismatch example that bit PRIA:
# dev (SQLite): must_change_password INTEGER DEFAULT 0  → works with 0/1 AND True/False
# prod (PG):    must_change_password INTEGER DEFAULT 0  → rejects True/False from Python

# FIX: declare BOOLEAN in both, OR always write integers from Python
```

### Idempotent type migration
```python
import os, psycopg2

def migrate_column_type(conn, table: str, col: str, new_type: str) -> None:
    """Alter column type if it doesn't already match. Safe to run on every boot."""
    cur = conn.cursor()
    cur.execute("""
        SELECT data_type FROM information_schema.columns
        WHERE table_name = %s AND column_name = %s
    """, (table, col))
    row = cur.fetchone()
    if not row:
        return  # column doesn't exist
    current = row[0].lower()
    if new_type.lower() in current:
        return  # already correct
    # USING clause handles cast — adjust per actual types
    cur.execute(f'ALTER TABLE {table} ALTER COLUMN {col} TYPE {new_type} USING {col}::{new_type}')
    conn.commit()

# Run at startup — no-op if already migrated
migrate_column_type(conn, 'users', 'must_change_password', 'BOOLEAN')
```

### Dev-vs-prod parity checklist
- [ ] Same DB engine locally if possible (Docker postgres — see `deployment-patterns`)
- [ ] If stuck with SQLite in dev, write integration tests against Postgres in CI
- [ ] Never store Python `True`/`False` into an INTEGER column — cast to `int(bool_value)` explicitly
- [ ] Use an ORM (SQLAlchemy) or Pydantic validator to normalize types before insert
- [ ] On first PG deploy: run `SELECT column_name, data_type FROM information_schema.columns WHERE table_name='X'` and compare to code expectations

## PostgreSQL Bulk Operations (psycopg2)

### Bulk Insert with `executemany`
```python
import psycopg2
import os

conn = psycopg2.connect(os.environ['DATABASE_URL'])
cur = conn.cursor()

# Bulk insert — efficient for 100s of rows
data_list = [
    ('2024-01-15', 'ACTIVE', 'John', 100),
    ('2024-01-16', 'PENDING', 'Jane', 200),
    # ... more rows
]

cur.executemany("""
    INSERT INTO orders (date, status, customer, amount)
    VALUES (%s, %s, %s, %s)
""", data_list)

conn.commit()
print(f"Inserted {len(data_list)} rows")
```

### Skip Duplicates with `ON CONFLICT DO NOTHING`
```python
cur.executemany("""
    INSERT INTO products (sku, name, price)
    VALUES (%s, %s, %s)
    ON CONFLICT (sku) DO NOTHING
""", data_list)
```

### JSON Backup & Restore
```python
import json

def backup_table(cur, table_name):
    """Backup table to JSON string"""
    cur.execute(f"SELECT * FROM {table_name}")
    rows = cur.fetchall()
    columns = [desc[0] for desc in cur.description]
    return json.dumps({'columns': columns, 'rows': rows}, default=str)

def restore_table(conn, cur, table_name, json_data):
    """Restore table from JSON backup"""
    data = json.loads(json_data)
    rows = data['rows']
    placeholders = ','.join(['%s'] * len(data['columns']))
    cur.executemany(
        f"INSERT INTO {table_name} VALUES ({placeholders})",
        rows
    )
    conn.commit()

# Usage
backup = backup_table(cur, 'products')
print(f"Backed up {len(json.loads(backup)['rows'])} rows")
```

## Data Migration Workflow (CRITICAL)

### Before ANY Bulk Data Operation
```
1. CREATE BACKUP first — never skip this
2. Verify backup exists and has correct row count
3. Inform user: "About to delete X rows and insert Y rows"
4. Wait for explicit confirmation
5. Execute operation
6. Verify: SELECT COUNT(*) FROM table
7. Spot-check: SELECT * FROM table LIMIT 5
```

### Backup Before Import Script Template
```python
import json
from datetime import datetime

def backup_before_import(conn, table_name, backup_dir="backups"):
    """Create timestamped backup before destructive operation"""
    cur = conn.cursor()
    cur.execute(f"SELECT * FROM {table_name}")
    rows = cur.fetchall()
    columns = [desc[0] for desc in cur.description]

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{backup_dir}/backup_{table_name}_{timestamp}.json"

    with open(filename, 'w') as f:
        json.dump({'columns': columns, 'rows': rows}, f, default=str)

    print(f"Backup created: {filename} ({len(rows)} rows)")
    return filename

# Usage
backup_file = backup_before_import(conn, 'products')
# ... user confirms ...
# ... perform import ...
# ... verify results ...
```

### Verification Queries
```sql
-- Check row counts
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM products WHERE category = 'electronics';

-- Check unique values
SELECT DISTINCT category FROM products ORDER BY category;

-- Spot-check specific record
SELECT * FROM products WHERE sku = 'ABC123' LIMIT 5;

-- Find potential duplicates (same unique key)
SELECT sku, COUNT(*)
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;

-- Find records by date range
SELECT * FROM orders
WHERE date >= '2024-01-01' AND date <= '2024-01-31'
ORDER BY date;
```