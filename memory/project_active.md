---
name: Active projects
description: Current projects Ruddy is working on — richer schema for auth, debt, creds, env
type: project
---

# Active Projects

For each project below: tech stack, deploy target, critical env vars, known issues / tech debt, test credentials (if safe to log here — never paste real secrets), and the single most important caveat.

## PRIA
- **What:** EdTech Streamlit app — teacher planning assistant
- **Stack:** Python 3.10, Streamlit + FastAPI, PostgreSQL on Railway, SQLite locally
- **Repo:** `ruddyribera-ops/pria-app` (private — see `project_gh_token_scope.md` for GH CLI gap)
- **Local path:** `C:\Users\Windows\Desktop\02_Proyectos\PRIA\PRIA DEPLOY`
- **Deploy target:** Railway project PRIAv5 → https://priav5-production.up.railway.app (see `reference_railway.md`)
- **Critical env vars:** `DATABASE_URL`, `RAILWAY_TOKEN`, Streamlit secrets under `.streamlit/secrets.toml` locally
- **Known issues / tech debt:**
  - PG↔SQLite type drift on `must_change_password` (see `database-patterns` type migration section)
  - Cold Railway startup can break e2e tests on fixed timers (see `feedback_e2e_waits.md`)
  - Empty prod DB requires seed-on-startup to have working login
- **Test credentials:** never committed; check Railway dashboard or ask user
- **Single most important caveat:** every new deploy starts with an empty DB — seed-on-startup is load-bearing, not optional
- **Beta milestone:** pilot with teachers at Las Palmas school — 3 weeks out from current date

## Palma Coin
- **What:** Classroom behavioral economics system — earns "Palma Coins" for effort/responsibility, student government, real-time voting, reward redemption
- **Stack:** Node.js + Express + `pg` (PostgreSQL via Railway plugin), React 19 + Vite, WebSocket, bcrypt
- **Repo:** `C:\Users\Windows\Desktop\01_Escuela\PLANIFICACION 2026\ECONOMIA DE FICHAS\Palma Coin\palma-coin-app`
- **Local path:** same as repo above
- **Deploy target:** https://palma-coin-production.up.railway.app ( Railway Docker, PostgreSQL persisted via Railway Postgres plugin)
- **Critical env vars:** `PORT=8080`, `NODE_ENV=production`, `DATABASE_URL` (provided by Railway Postgres plugin — link in Railway dashboard: App Service → Settings → Linked Plugins → add Postgres)
- **Known issues / tech debt:**
  - **HIGH:** WebSocket `/ws` not proxied by Railway TCP gateway — live updates broken in production (WS connects but immediately errors/disconnects). Backend is fully WS-capable; the issue is Railway's TCP proxy not forwarding WebSocket traffic to the container port 8080.
  - **HIGH:** `plain_password` column removed — was storing unhashed passwords in plaintext (fixed Apr 2026)
  - **HIGH:** `x-user-role` header spoofing — fixed Apr 2026 (isTeacher now looks up role by DB id, not client header)
  - **MEDIUM:** No pagination on transactions/purchases — now has `?page=&limit=` query params (fixed Apr 2026)
  - **MEDIUM:** `assembly_votes` and `autonomy-metrics` had no auth — now protected by `isAuthenticated`/`isTeacher` middleware
  - **LOW:** Rewards.jsx typo "student que will" → "estudiante que" (fixed Apr 2026)
- **Test credentials:** Teacher: `ruddy@laspalmas.edu.bo` / `palma2026` | Students: `[name]@laspalmas.edu.bo` / `estudiante123`
- **Single most important caveat:** PostgreSQL is now the primary data store (migrated Apr 2026). The `DATABASE_URL` must be linked via Railway's plugin system — the app fails fast with a clear error if it's missing. Delete `palma.db` (old SQLite file) before committing.

**How to apply:** when Ruddy mentions "PRIA" or "Palma", pull facts from here. Before acting on anything production-adjacent (deploy, migration, auth change), read the "known issues" line — chances are the issue was already seen and documented. Check project-local `./.opencode/memory/` first if present — those entries override this global file.

## Math Platform
- **What:** Khan Academy + Duolingo-style math learning platform for Bolivian school
- **Stack:** Python 3.12 FastAPI + SQLAlchemy async, Next.js 14 App Router, PostgreSQL, Redis, Docker Compose
- **Local path:** `C:\Users\Windows\math-platform`
- **Deploy target:** Docker Compose locally (dev); Railway possible for prod
- **Critical env vars:** `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`, `JWT_REFRESH_SECRET`
- **Known issues / tech debt:**
  - `pydantic._internal._signature` missing in local Python env — use Docker exclusively for testing
  - Playwright blocked by Windows Defender EACCES — test with knowledge from training data
  - Docker Desktop daemon pipe (`desktop-linux`) drops mid-session — restart Docker Desktop app
  - Postgres volume must be wiped (`docker compose down -v`) only when schema changes; for column additions use `ALTER TABLE`
  - `AssignmentCreateRequest.class_id` is optional in body for URL-scoped endpoint (comes from URL path)
  - `submit_attempt` decorator lost in Phase 5 edit — restored in Phase 6 (always verify decorator present)
  - **Router prefix bug:** When adding a new router to `main.py`, double-check the prefix matches what the frontend API client expects. Wrong prefix silently 404s every endpoint. Student endpoints at `/me/...` must go in `students.py` (prefix `/api/me`) not `assignments.py` (prefix `/api/assignments`) — always verify via OpenAPI paths after adding routes.
- **Test credentials:** Register via `POST /api/auth/register` — no seed users committed
- **Database:** `math_platform` (underscore), not `mathplatform`
- **Single most important caveat:** Docker must be running before any `docker compose` command — daemon check is mandatory before build

**How to apply:** when Ruddy mentions "math platform" or "learning platform", pull facts from here. Phase 7 complete as of 2026-04-20.

## Template for new projects

```markdown
## <Project Name>
- **What:** <one-line purpose>
- **Stack:** <languages + frameworks + DB>
- **Repo:** <org/repo + private/public + any access gaps>
- **Local path:** <absolute path>
- **Deploy target:** <platform + URL + project ID if Railway/Render>
- **Critical env vars:** <names, not values>
- **Known issues / tech debt:** <bulleted list of real gotchas, link to memory files>
- **Test credentials:** <how to get them — never paste secrets here>
- **Single most important caveat:** <the one thing that will burn you if forgotten>
```
