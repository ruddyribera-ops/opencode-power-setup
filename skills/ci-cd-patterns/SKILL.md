---
name: ci-cd-patterns
description: GitHub Actions CI/CD pipeline patterns, git hooks, and automated quality checks
---

# CI/CD Patterns

## GitHub Actions — Node.js Project

```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm run lint --if-present
      - run: npx tsc --noEmit --if-present
      - run: npm run build --if-present
      - run: npm test --if-present
```

## GitHub Actions — Python Project

```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'
      - run: pip install -r requirements.txt
      - run: pip install pytest flake8
      - run: flake8 . --max-line-length=120 --exclude=venv,__pycache__
      - run: pytest --tb=short -q
```

## GitHub Actions — Deploy to Railway

```yaml
  deploy:
    needs: ci
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: railwayapp/deploy-action@v1
        with:
          railway_token: ${{ secrets.RAILWAY_TOKEN }}
```

## GitHub Actions — Deploy to Vercel

```yaml
  deploy:
    needs: ci
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

## Adapt to Project (IMPORTANT)

Before creating any CI/CD pipeline:
1. **Read `package.json` scripts** → use what exists (`lint`, `test`, `build`)
2. **Check for existing `.github/workflows/`** → don't create duplicates
3. **Match the project stack** → don't add Node steps to a Python project
4. **Only add deploy step** if the user has a deployment platform configured
5. **Use `--if-present`** for optional scripts (lint, build) so CI doesn't fail if script doesn't exist

## Git Hooks — Husky + lint-staged (Node.js)

### Setup
```bash
npm install -D husky lint-staged
npx husky init
```

### Pre-commit hook (.husky/pre-commit)
```bash
npx lint-staged
```

### package.json addition
```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{css,md,json,yaml}": "prettier --write"
  }
}
```

## Git Hooks — Pre-commit (Python)

### .pre-commit-config.yaml
```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 24.4.2
    hooks:
      - id: black
  - repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
      - id: flake8
        args: [--max-line-length=120]
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
```

### Setup
```bash
pip install pre-commit
pre-commit install
```

## When to Add What

| Project state | Add this |
|---------------|----------|
| No CI at all | Basic CI workflow (lint + test + build) |
| CI exists, no deploy | Add deploy job to existing workflow |
| No git hooks | Husky + lint-staged (Node) or pre-commit (Python) |
| Has hooks, no CI | GitHub Actions workflow |
| Everything exists | Don't touch it — skip |
