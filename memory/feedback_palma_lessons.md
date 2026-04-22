---
name: palma-coin-lessons
description: Lessons learned from Palma Coin — apply to all future projects
type: feedback
date: 2026-04-19
---

# Palma Coin — Lessons Learned

**Rule for memory files:** Only save lessons that would genuinely surprise a developer joining a new project. Skip: obvious knowledge, language fundamentals, platform basics, and project diaries. Fit the file on one screen.

---

## 1. Always Sync Local with Remote Before Auditing Code

Before touching any codebase, run `git fetch + git log --oneline origin/main`. Remote may have unseen commits (from dashboard edits, other machines, Railway auto-deploys). In Palma Coin, we spent time "fixing" something the remote had already fixed.

**How to apply:** Every session start — fetch first, audit second, change third.

---

## 2. Never Trust `x-user-role` from Request Headers

Client-supplied auth headers (`x-user-role`, `x-user-name`) are always spoofable. Any client can set `x-user-role: teacher` and bypass authorization. Server-side must validate from a trusted source: DB lookup, JWT cookie, or server session.

**How to apply:** When writing `isTeacher` / `requireAuth` middleware — always query the DB or verify the JWT server-side. Never read role from `req.headers`.

---

## 3. sql.js + Railway Ephemeral Filesystem = Data Death

Railway containers are ephemeral — every redeploy wipes the filesystem. sql.js persists to a `.db` file on the container's disk. Every push wiped all student data and reset to the seed. This applies to any embedded DB (SQLite, sql.js, LevelDB) on Railway, Render, Fly.io, or any other ephemeral-hosting platform.

**How to apply:** For Railway deployments, use Railway's Postgres plugin from day one. Never rely on container filesystem for persistent data.

---

## 4. WebSocket on Railway Requires Explicit TCP Proxy Configuration

Local WebSocket (`ws://localhost:PORT/ws`) works fine. On Railway, the TCP gateway doesn't automatically forward WebSocket upgrade requests to the container. The WS connects then immediately errors/disconnects with no useful error message.

**How to apply:** When building real-time features, test WebSocket in production early. If it breaks on Railway, either enable Railway's TCP networking or fall back to Server-Sent Events or polling — don't assume it works because it works locally.

---

## 5. Railway-Branded 404 ≠ App 404

Railway's own branded 404 page (with the pink/purple gradient) means Railway received the request but the app inside the container isn't serving it. Usually a port mismatch (app binds to wrong port) or the Docker CMD didn't run.

**How to apply:** When you see Railway's 404, don't assume the app is down — check `railway logs` and verify the container is actually running Express on the right port.

---

## 6. PostgreSQL `RETURNING *` Replaces `last_insert_rowid()`

SQLite's `last_insert_rowid()` has no PostgreSQL equivalent. Every `INSERT` must use `RETURNING *` or `RETURNING id` to get the inserted row immediately. This affects every create-then-read pattern in the codebase.

**How to apply:** When migrating from SQLite to PostgreSQL, replace all `last_insert_rowid()` calls with `INSERT ... RETURNING *` — and make it a search/replace rule, not a manual audit.

---

## 7. Seeds Must Use `ON CONFLICT DO NOTHING`

`initDb()` runs on every startup. If seeds insert rows that violate UNIQUE constraints (email, name), the app crashes. Every insert in seed code must be wrapped with `ON CONFLICT (...) DO NOTHING`.

**How to apply:** Any seed/upsert function must be idempotent — safe to run on a database that already has the data.

---

## 8. Audit Actual Remote Code Before Deciding What Is Broken

When we audited the server for `x-user-role` spoofing, we found the remote already had the fix (JWT auth, `authenticate()` middleware). We "fixed" something that wasn't broken. We didn't know because we never fetched and read the actual remote state.

**How to apply:** Before changing any file, run `git fetch origin` + read the actual file from the remote branch. Don't assume local state == remote state.