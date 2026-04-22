# Desktop Manager Skill

## Purpose
Run desktop cleanup scripts using natural language (English or Spanish)

## Triggers (natural language)
- "scan my desktop"
- "organize my desktop"
- "cleanup my desktop"
- "limpieza de escritorio"
- "escanear escritorio"
- "organizar escritorio"
- "quick cleanup"
- "dry run cleanup"

## Scripts Location
`C:/Users/Windows/scan-desktop.ps1` - Scan only (no changes)
`C:/Users/Windows/quick-cleanup.ps1` - Quick cleanup to external drive
`C:/Users/Windows/cleanup-desktop.ps1` - Full interactive cleanup

## Usage

### Scan Desktop (Preview)
Shows desktop contents without moving anything:
```
.\scan-desktop.ps1
```

### Quick Cleanup
Fast cleanup to external disk F:\:
```
.\quick-cleanup.ps1
```

### Full Cleanup
Interactive with preview:
```
.\cleanup-desktop.ps1
```

### Dry Run
Preview what would happen without moving files:
```
.\cleanup-desktop.ps1 -DryRun
```

## Implementation

When user asks to scan/organize/cleanup desktop in natural language:

1. Detect intent from natural language
2. Run appropriate script:
   - "scan" / "escanear" / "what's on" → scan-desktop.ps1
   - "cleanup" / "limpieza" / "organize" / "organizar" → quick-cleanup.ps1 (default)
   - "dry run" / "preview" → cleanup-desktop.ps1 -DryRun

3. Output results to user

## Notes
- Scripts require PowerShell 5.1+
- External backup drive defaults to F:\
- Scripts create timestamped backup folders
- No files are deleted, only moved to backup
