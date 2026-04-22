---
name: Railway deploy surface for PRIA
description: Project / service IDs and URL for the PRIAv5 Railway deployment.
type: reference
---

- Public URL: https://priav5-production.up.railway.app
- Health probe: `GET /` returns HTTP 200 when healthy; `/_stcore/health` is Streamlit's internal probe.
- Railway project ID: `bafe10b7-ca26-4b89-a715-59dd33c4632c`
- Service ID (PRIAv5): `0f9e5a32-0d1e-4a23-a35d-a01f6f9a8997`
- Deploys trigger automatically from GitHub Actions on push to `main` (see `.github/workflows/ci.yml`, `deploy` job uses `@railway/cli` with `RAILWAY_TOKEN` secret).
- Known quirk: Railway sometimes reuses a cached build even with `railway up --detach`. If a deploy looks stuck on old code, consider `railway remove` + fresh deploy, or introduce a cache-busting variable.
