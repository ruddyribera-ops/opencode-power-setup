---
type: feedback
created: 2026-04-18
tags: [express, route-order, backend]
---

# Feedback — Learned Rules

## Route Order in Express (Critical)
Express matches routes in registration order. The catch-all `app.get("*")` and static middleware `app.use(express.static)` MUST be registered AFTER all API routes. If placed before, `/api/*` requests return the SPA `index.html` instead of JSON.

**Rule:** When adding new API routes, always register them before any `app.use("*")` or `app.use(express.static)` middleware.

**Why:** Express walks the middleware stack in order. The first matching route wins. The catch-all `*` matches all paths including `/api/version`, `/api/health`, etc.

---

## Railway Deploy Lessons (Critical)

### Long Paths Break Railway CLI
Windows paths with spaces ("BDM LASTEST VERSION") cause "Acceso denegado" errors when `railway up` tries to index. Keep a separate short-path clone of the repo for deployments.

**Rule:** Keep `C:\railway-deploy` as a dedicated `git clone` of the project's origin. On deploy: `cd C:\railway-deploy && git pull origin BRANCH && railway up --detach`. This is cleaner than copying files and guarantees the deploy matches what's on GitHub.

### Railway CLI Service Linking
When linked service is lost (fresh clone, new machine), use `railway service link "SERVICE_NAME"` once — the link is stored in `.railway/` inside that directory and persists across sessions.

### Railway Build Caching
Railway may cache old builds even after a successful git push. If API endpoints return HTML after a deploy, the fix is likely correct but Railway hasn't picked it up yet. Force-redeploy from the Railway dashboard.

**Rule:** After any server.js change affecting routing, always verify `/api/version` returns JSON (not HTML) before declaring the deploy done.

### Dockerfile Must Build dist
Railway's default Node railpack does NOT run `npm run build`. The `dist/` folder is never created unless the Dockerfile explicitly runs `npm run build`. The multi-stage builder approach that only copied `dist` from builder failed because `dist` was never generated.

**Rule:** Dockerfile MUST contain `RUN npm ci && npm run build` in the same stage that runs `node server.js`. Single-stage builds work: `FROM node:20-alpine` + `RUN npm ci && npm run build` + `CMD ["node", "server.js"]`.

### Static Files Not Served — Real Root Cause
After fixing the Dockerfile, `/` still returned 404 while `/api/version` worked. **The initial hypothesis (Railway proxy / Caddy routing) was wrong.** The actual cause: `server.js` had an Express 404 handler (`app.use((req, res) => res.status(404).json(...))`) registered BEFORE the `express.static(dist)` + `app.get("*")` catch-all. Express walks middleware in registration order, so the 404 handler caught `/` before static could serve `index.html`.

**Rule:** Middleware order in Express is strict. For an SPA: `API routes → express.static → app.get("*") catch-all → 404 handler → error handler`. The 404 handler must come AFTER static, not before.

**How to diagnose:** If `/` returns 404 but `/api/*` works, check the 404 body. `{"error":"Not found"}` + `x-powered-by: Express` means the 404 is Express, not the proxy. Railway's proxy 404 returns HTML, not JSON with that shape. See also: [feedback_debug_hypothesis.md](feedback_debug_hypothesis.md) for the general body+headers diagnostic pattern.

---

## Validate Locally Before Deploy
Boot the server locally and curl every endpoint that matters — especially the one that's broken — BEFORE pushing a server-side fix. Middleware-order bugs only surface at runtime; lint and unit tests miss them entirely.

**Rule:** `PORT=3457 node server.js &` → `curl localhost:3457/` + `curl localhost:3457/api/version` → confirm expected body + status → stop → THEN commit/push. Don't skip for "trivial" reorderings — that's exactly when reality diverges from your mental model.

**Why:** On 2026-04-18 the 10-second local check is what proved the 404 handler reorder actually fixed `/` before we shipped. The same check, run against the pre-fix server, would also have caught the bug in the first place.

---

## Always Fix Lint Before Commit
ESLint errors that pass locally may fail CI. The `_next` parameter in Express error handlers triggered `no-unused-vars` until we added `argsIgnorePattern: '^_'` to the ESLint rule.

**Rule:** Run `npm run lint` before every commit. Don't let lint errors accumulate.

---

## Source: BDM App sessions (2026-04-18) — rules generalized for reuse across Node/Express + Railway projects
