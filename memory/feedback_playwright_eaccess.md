---
name: Playwright MCP EACCESS on Windows inside OpenCode
description: "EACCESS / permission denied when Playwright MCP runs inside OpenCode AI tool. Browser binary is installed correctly but MCP server can't execute it."
type: feedback
---

# Playwright MCP EACCESS Fix — Windows + OpenCode

**Why:** Ruddy gets EACCESS when Playwright MCP (invoked as child process via opencode.json) tries to launch a browser. Investigation shows browsers ARE installed correctly and direct launch works — the issue is specific to the MCP server's child process invocation.

**Root causes (in order of likelihood):**

1. **Windows Defender / security software blocking the browser executable** — real-time scanning causes EACCESS when the MCP server spawns chromium. The executable itself is fine (direct test works); only the spawned child process triggers the block.
2. **Stale browser user data directory** — a previous browser instance left a lock file in `%LOCALAPPDATA%\Temp` or the browser profile dir. Subsequent launches fail with EACCESS.
3. **Version mismatch** — `@playwright/mcp@0.0.70` has a pre-release `playwright-core@1.60.0-alpha-1774999321000` dependency that may have different browser requirements than the installed `chromium-1217`.

**How to apply when EACCESS appears during Playwright MCP use:**

1. **Run Windows Defender exclusion** (PowerShell — must be run as Administrator):
   ```powershell
   Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\ms-playwright"
   Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp\playwright-*"
   ```
   Then restart OpenCode.

2. **Clear stale temp files** if Defender exclusion doesn't resolve it:
   ```powershell
   Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Temp\playwright-*" -ErrorAction SilentlyContinue
   Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Temp\.playwright-*" -ErrorAction SilentlyContinue
   ```

3. **Reinstall the MCP package** if still failing:
   ```powershell
   npm uninstall -g @playwright/mcp
   npx -y @playwright/mcp@latest
   ```

4. **Verify** by running in a PowerShell terminal (outside OpenCode) first:
   ```powershell
   node -e "const {chromium} = require('playwright-core'); chromium.launch({headless:true}).then(b => { console.log('OK'); b.close(); }).catch(e => console.log('FAIL:', e.code))"
   ```
   If this fails outside OpenCode, the issue is system-wide (Defender, permissions, or browser install). If it succeeds outside OpenCode but fails inside, the issue is OpenCode's process spawning.

**The actual MCP config (opencode.json) is correct:**
```json
"playwright": {
  "command": ["npx", "-y", "@playwright/mcp@latest", "--headless"],
  "type": "local",
  "enabled": true
}
```
No path or env changes needed — the EACCESS is a runtime block, not a config error.