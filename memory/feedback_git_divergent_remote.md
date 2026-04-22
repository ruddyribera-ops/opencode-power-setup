---
name: Handling force-pushed or squashed remote branches
description: When git push is rejected because remote diverged (force-push, squash, orphan commit), investigate common ancestor and file contents before acting — default rebase often explodes.
type: feedback
---

# When the remote has diverged heavily

**Rule:** If `git push` is rejected with "remote contains work you don't have", do NOT immediately run `git pull` or `git rebase origin/BRANCH`. Fetch first, then inspect the divergence. A rebase against a force-pushed or squashed remote can try to replay every commit in your local history and generate massive conflicts.

**Why:** On BDM App 2026-04-18, remote `master` had been replaced by a single squash commit that shared no history with local. `git rebase origin/master` attempted to replay ~15 local commits onto the orphan root, exploding into conflicts in 7+ files including `package-lock.json` and `App.jsx`. Aborting + inspecting revealed the situation: same content, different shape.

**How to apply:**

1. **Fetch, don't pull:**
   ```bash
   git fetch origin
   ```

2. **Inspect the divergence:**
   ```bash
   git log --oneline HEAD..origin/BRANCH   # remote-only commits
   git log --oneline origin/BRANCH..HEAD   # local-only commits
   git merge-base HEAD origin/BRANCH       # common ancestor (empty output = no shared history)
   git log --oneline --graph --all -20     # visual
   ```

3. **Look for warning signs:**
   - `+ SHA1...SHA2 branch -> origin/branch (forced update)` in fetch output
   - `git merge-base` returns empty → no common history (orphan commit on one side)
   - Remote has 1 commit but contains the full project → squash-all

4. **Compare actual file contents, not just git state:**
   ```bash
   git show origin/BRANCH:path/to/file > /tmp/remote.txt
   # Normalize line endings on Windows (CRLF vs LF trap):
   sed 's/\r$//' path/to/file > /tmp/local.txt
   diff /tmp/remote.txt /tmp/local.txt
   ```
   Often the actual code difference is tiny — it's the history that diverged.

5. **Decide intentionally, and announce before acting:**
   - **Align local to remote** (you accept the squash): `git reset --hard origin/BRANCH` + manually re-apply your changes + commit + push. Destructive to local only; reflog preserves for ~90 days.
   - **Force-push your history** (you reject the remote shape): confirm with user first — this is destructive to shared state.
   - **Never** silently rebase against a divergent remote and resolve conflicts blind; the resulting commit will contain content the user didn't intend.

**Anti-pattern:** running `git pull --rebase` or `git rebase origin/BRANCH` as a reflex when push is rejected, without checking whether the remote is a force-push/squash. Inspection first is always cheaper than conflict resolution in a broken rebase.
