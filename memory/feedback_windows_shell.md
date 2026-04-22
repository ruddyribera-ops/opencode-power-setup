---
name: Windows shell gotchas (machine-wide) — PowerShell FIRST, git bash second
description: Ruddy runs commands in Windows PowerShell most of the time. Every command the agent SHOWS for manual run must be PowerShell-compatible. Only internal Bash-tool calls can use POSIX.
type: feedback
---

# Rule of Thumb

**Two contexts, two syntaxes. Know which one you're in:**

| Context | Shell | Syntax |
|---------|-------|--------|
| Agent runs it via the Bash tool | Git Bash (MINGW64) | POSIX works |
| Agent SHOWS user a command to copy-paste | **PowerShell 5.1 / 7** | PowerShell syntax required |
| Scripts saved under `scripts/` | PowerShell | `.ps1` |

**Default assumption: if you are telling the user to run a command in their terminal, it is PowerShell. When in doubt, output PowerShell.**

## Top-15 Bash → PowerShell Translations (the ones that bite)

| Bash (will FAIL in PS 5.1) | PowerShell equivalent |
|---|---|
| `export FOO=bar` | `$env:FOO = 'bar'` |
| `FOO=bar command` | `$env:FOO='bar'; command` |
| `cmd1 && cmd2` | `cmd1; if ($?) { cmd2 }` (PS 5.1) OR `cmd1 && cmd2` (PS 7+) |
| `cmd1 \|\| cmd2` | `cmd1; if (-not $?) { cmd2 }` (PS 5.1) |
| `echo $VAR` | `echo $env:VAR` or `$env:VAR` |
| `echo $HOME` | `$HOME` (built-in in PS — works) |
| `cat file \| grep foo` | `Get-Content file \| Select-String foo` |
| `find . -name "*.py"` | `Get-ChildItem -Recurse -Filter *.py` |
| `ls -la` | `ls` (alias works) or `Get-ChildItem -Force` |
| `rm -rf dir` | `Remove-Item -Recurse -Force dir` |
| `curl URL` | `curl.exe URL` OR `Invoke-WebRequest URL` (bare `curl` is alias for IWR) |
| `which cmd` | `Get-Command cmd` |
| `touch file.txt` | `New-Item file.txt` or `'' > file.txt` |
| `source script.sh` | N/A — use `. .\script.ps1` for PS scripts |
| heredoc `cmd <<EOF ... EOF` | here-string `@"..."@` (expands) or `@'...'@` (literal) |
| line continuation `cmd \ ` | backtick at end of line: `cmd` ` |
| `cmd > /dev/null 2>&1` | `cmd *> $null` |

## Common Recurring Mistakes (the ones Ruddy has corrected before)

1. **`&&` in user-facing commands** — safe only on PS 7+. If unsure, use `;` + `if ($?)`.
2. **`$VAR` without `$env:` prefix** — bash syntax, fails silently in PS (expands to nothing).
3. **Heredocs** — do NOT exist in PS. Use `@"..."@` here-strings or write to a `.ps1` file.
4. **Single quotes vs double quotes** — PS: `'literal'` (no interpolation), `"$env:FOO"` (interpolation). Don't mix.
5. **Backslashes in paths** — PS accepts both `/` and `\`, but bash tools mangle `\`. Default to `/` or quote with single quotes.
6. **`sudo`** — doesn't exist. Either elevate the whole PS session ("Run as Administrator") or use `Start-Process -Verb RunAs`.
7. **`export`** — doesn't exist. Use `$env:NAME='value'`. Persists only for the current session.
8. **`xargs`** — not native. Use `ForEach-Object`: `ls *.py | ForEach-Object { python $_.Name }`.

## CRLF / LF Trap (cross-platform diff)

Files on Windows have CRLF, `git show origin/BRANCH:file` outputs LF. Raw `diff` = every line marked changed. Normalize first:

```powershell
(Get-Content file) -replace "`r$", "" | Set-Content /tmp/local.txt
```

Or in bash: `sed 's/\r$//' file > /tmp/local.txt`.

## PowerShell-from-Bash (ugly but sometimes needed)

Inline `powershell -Command "$_ stuff"` gets mangled by bash parameter expansion. Fix:
- Write to `script.ps1`, call `powershell -File script.ps1`
- Or escape `$` as `\$` and use single quotes around the whole `-Command` arg

## How to Apply

- **Before showing the user ANY command to copy-paste**, check: is this PowerShell-safe? If not, translate using the table above.
- If the command involves piping, env vars, or chaining → default to writing a `.ps1` script under `~/.config/opencode/scripts/` and tell the user to run `powershell -File <path>`.
- When a command fails with "unexpected EOF", "The term 'export' is not recognized", or "variable $X is null" → it's bash-in-PowerShell. Rewrite.
- **Self-check rule:** if you just typed `&&`, `export`, `$VAR` (no `$env:`), or `<<EOF` in a command meant for the user — STOP. Translate first.

## Why

Ruddy has corrected this same category of mistake repeatedly across PRIA sessions. Commands like `export DATABASE_URL=...` and `cmd1 && cmd2` paste into PowerShell and fail silently or loudly. The fix lives here so the coordinator and every specialist can find it.
