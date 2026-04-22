---
name: git-workflow
description: Conventional commits, branch naming, git hooks, and safe git practices
---

# Git Workflow Standards

## Commit Format (Conventional Commits)
```
type(scope): short description

Body (optional): explain WHY not WHAT
Closes #issue
```

Types: feat | fix | docs | style | refactor | test | chore | perf | ci

Examples:
- feat(auth): add OAuth2 login with Google
- fix(api): handle null response from /users endpoint
- refactor(db): extract connection pool to separate module
- ci(github): add automated test pipeline
- chore(deps): update express to v5

## Branch Naming
- feature/short-description
- fix/issue-number-description
- chore/task-description
- release/v1.2.0

## Safe Git Operations
Always confirm before:
- git push (especially to main/master)
- git reset --hard
- git rebase
- git clean

Never use without asking:
- git push --force (use --force-with-lease instead)
- git clean -fdx

## Pre-Commit Checklist
1. Run tests: `npm test` / `pytest` / `go test ./...`
2. Run lint: `npm run lint` / `flake8` / `golint`
3. Review diff: `git diff --staged`
4. Write meaningful commit message

## Git Hooks Setup (Node.js — Husky)

### Install
```bash
npm install -D husky lint-staged
npx husky init
echo "npx lint-staged" > .husky/pre-commit
```

### package.json
```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{css,md,json}": "prettier --write"
  }
}
```

## Git Hooks Setup (Python — pre-commit)

### Install
```bash
pip install pre-commit
pre-commit install
```

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
```

## Common Git Workflows

### Feature branch workflow
```bash
git checkout -b feature/my-feature
# ... work ...
git add .
git commit -m "feat(scope): description"
git push -u origin feature/my-feature
# Create PR via: gh pr create --title "feat: description" --body "summary"
```

### Quick fix workflow
```bash
git checkout -b fix/issue-description
# ... fix ...
git add .
git commit -m "fix(scope): description"
git push -u origin fix/issue-description
```

### Stash workflow (save work temporarily)
```bash
git stash                    # Save current changes
git stash list               # See stashed items
git stash pop                # Restore latest stash
git stash drop               # Delete latest stash
```
