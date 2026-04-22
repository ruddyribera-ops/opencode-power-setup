---
name: deployment-patterns
description: Docker, docker-compose, Railway, containerization, and environment configuration
---

# Deployment Patterns

## Dockerfile — Node.js (Multi-stage)
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## Dockerfile — Simple Node.js (No build step)
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install && npm run build
EXPOSE 8080
CMD ["node", "server/index.js"]
```

Common mistakes:
- `COPY package*.json ./` only → missing source code
- Not building frontend before server start
- Wrong entry point path

## Dockerfile — Python
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## .dockerignore
```
node_modules
dist
.git
.env*
*.log
coverage
.pytest_cache
__pycache__
venv
.venv
```

## docker-compose.yml — Node.js + PostgreSQL
```yaml
services:
  app:
    build: .
    ports:
      - "${PORT:-3000}:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

## docker-compose.yml — Python + PostgreSQL
```yaml
services:
  app:
    build: .
    ports:
      - "${PORT:-8000}:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

## Port Configuration
```javascript
// Always use environment variable
const PORT = process.env.PORT || 3001;
server.listen(PORT, () => console.log(`Running on port ${PORT}`));
```

Container platforms (Railway, Render, Fly.io) set `PORT` automatically.

## API URLs in Frontend
```javascript
// ✅ Good: Relative URLs work in dev AND production
fetch('/api/users')
fetch('/api/login')

// ❌ Bad: Hardcoded localhost breaks in production
fetch('http://localhost:3001/api/users')
```

## Web Proxy (Dev Server)
For Vite:
```javascript
// vite.config.js
export default {
  server: {
    proxy: {
      '/api': { target: 'http://localhost:3001', changeOrigin: true },
      '/ws': { target: 'ws://localhost:3001', ws: true }
    }
  }
}
```

## Environment Variables
```bash
# .env.example (commit this — documents required vars)
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
NODE_ENV=development
JWT_SECRET=change-me-in-production
```

Rules:
- `.env` → in `.gitignore` (never commit)
- `.env.example` → commit (documents what's needed)
- Production → set in platform dashboard (Railway, Render, etc.)

## Pre-Deployment Checklist
- [ ] All API URLs use relative paths (`/api` not `localhost:3001`)
- [ ] WebSocket URL uses `window.location` for host
- [ ] `PORT` env var used, not hardcoded
- [ ] Dockerfile copies all source files
- [ ] Frontend builds successfully before server starts
- [ ] CORS configured for production domain
- [ ] Environment variables documented in `.env.example`

## Railway CLI Commands
```bash
# Deploy
railway up --detach        # Deploy without watching logs
railway up                 # Deploy with live logs

# Monitor
railway status             # Current project/service status
railway logs --tail 50     # Debug startup issues

# Run scripts in Railway context
railway run python script.py
railway run node script.js

# Project management
railway project link -p <project-id>
railway project list
```

## Railway Deployment Checklist
- [ ] Verify DATABASE_URL in Railway dashboard matches production DB
- [ ] Check `railway status` before deploying
- [ ] Run `railway logs --tail 30` after deploy to verify startup
- [ ] Confirm app responds at the production URL
- [ ] If deploy fails: check logs first, verify all env vars set

## Post-Push Verification (Don't Trust "git push")

**Problem:** you push, platform caches the old build, you test stale code and chase phantom bugs.

### After every push, verify the live version matches
```bash
# Your local commit
git rev-parse HEAD

# What's actually deployed (if your app exposes /version or /health returning commit)
curl -s https://your-app.up.railway.app/version

# If they match → safe to smoke test
# If they don't match → deploy hasn't rolled yet, or got cached. Wait or force-redeploy.
```

### Expose your commit hash in the app
```python
# Python (FastAPI / Streamlit): embed build-time commit
import os
APP_COMMIT = os.environ.get("RAILWAY_GIT_COMMIT_SHA", "unknown")[:7]

@app.get("/version")
def version():
    return {"commit": APP_COMMIT}
```

```javascript
// Node: same idea
const APP_COMMIT = process.env.RAILWAY_GIT_COMMIT_SHA?.slice(0, 7) || "unknown";
app.get("/version", (_, res) => res.json({ commit: APP_COMMIT }));
```

Railway auto-injects `RAILWAY_GIT_COMMIT_SHA`. Render/Fly/Vercel have similar vars.

### Post-Push Protocol
1. `git push` → wait for CI to report success
2. Wait ~30s for platform to roll the build
3. `curl /version` → confirm commit hash matches local HEAD
4. Only then run smoke tests against prod
5. If `/version` never matches: `railway logs --tail 50` to see why

**Never declare a deploy "done" until the live commit hash matches what you pushed.**

## First-Production-Deploy Checklist

A fresh DB is empty. A fresh app is unconfigured. Don't assume users/data/settings exist.

- [ ] Default admin user is seeded (see `database-patterns` seed-when-empty pattern)
- [ ] Default non-admin users seeded if the app needs them (demo accounts, teacher accounts, etc.)
- [ ] Test login with real credentials against prod URL (not just local)
- [ ] Verify live DB schema matches code expectations: `SELECT column_name, data_type FROM information_schema.columns WHERE table_name='users'`
- [ ] Confirm all secrets are set in platform dashboard (not just `.env`)
- [ ] Smoke-test the critical path end-to-end (login → main action → logout)
- [ ] Verify logs show no startup errors (`railway logs --tail 50`)
- [ ] Health endpoint returns 200 (`curl /health` or platform's probe URL)

**Seed-on-startup reminder:** if the app needs users/config present to function, seed on every boot (idempotent: check count, insert only if empty). See `database-patterns`.

## Platform Quick Reference
| Platform | Config File | Notes |
|----------|-------------|-------|
| Railway | `railway.toml` | Auto-detects Dockerfile |
| Vercel | `vercel.json` | Serverless functions |
| Netlify | `netlify.toml` | Static + functions |
| Render | `render.yaml` | Auto-suspends free tier |
| Fly.io | `fly.toml` | Edge deployments |
