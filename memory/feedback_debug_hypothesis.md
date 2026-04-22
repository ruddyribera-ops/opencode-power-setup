---
name: Diagnose 4xx/5xx with response body + headers before blaming infra
description: General debugging discipline — check the response body and headers to identify which layer (app/proxy/CDN) returned the error before proposing infrastructure-level fixes.
type: feedback
---

# Diagnose with evidence, not guesses

**Rule:** When an HTTP endpoint returns an unexpected status (404, 502, etc.), inspect the response **body** and **headers** before proposing a cause. They tell you which layer generated the response.

**Why:** On the BDM App (2026-04-18), we spent a full session hypothesizing "Railway proxy / Caddy routing `/` to a default 404" when the real cause was an Express middleware order bug. A single `curl -v` would have shown `{"error":"Not found"}` + `x-powered-by: Express` — unambiguous proof the 404 came from the Node app, not the proxy. The wrong hypothesis made it into memory and nearly poisoned the next session too.

**How to apply:**

1. **Before forming a hypothesis, run:**
   ```bash
   curl -s -o /dev/null -w "%{http_code}\n" URL         # status
   curl -s URL | head -c 300                             # body shape
   curl -sI URL | head -15                               # headers
   ```

2. **Read the signals:**
   - `x-powered-by: Express` / `Next.js` → your Node app is responding
   - `server: nginx` / `caddy` / `cloudflare` / `railway-edge` → proxy or CDN layer
   - `content-type: application/json` with app-shaped body (`{"error":"..."}`) → your app
   - `content-type: text/html` with a branded error page → proxy / CDN default
   - No `x-powered-by` + generic HTML → likely proxy or CDN default 404
   - `x-cache: HIT` → CDN is serving a cached response (may be stale)

3. **If the response came from your app, the bug is in your code.** Don't go looking for infrastructure causes. Reorder middleware, fix routes, check handler registration — whatever the specific symptom says.

4. **If the response came from the proxy/CDN,** then start looking at routing rules, Caddyfile, Nginx config, Cloudflare rules, Railway domain settings, etc.

**Anti-pattern caught:** Writing a memory that says "X is a proxy-layer issue" without having verified the body/headers. If a future session's guidance starts with "the proxy is routing to...", demand the curl evidence before acting on it.
