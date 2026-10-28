# Rules for AI agents and builders working in this repository

These rules apply to every AI coding agent (Claude Code, Codex and others) and every person
building here. Claude Code reads `CLAUDE.md`, which points to this file. Codex reads this file
directly.

## How changes get in

1. **One task, one branch.** Name it `agent/<short-task-name>` or `feat/<short-task-name>`.
   Work in your own git worktree (`git worktree add ../wt-<task> -b agent/<task>`), never in
   a folder another agent is using.
2. **Never push to `main`.** GitHub will refuse it anyway. Every change arrives as a pull request
   using the template.
3. **Commit only the files you changed for this task.** Use `git add <path> <path>`.
   Never use `git add -A`, `git add .` or `git commit -a`. They sweep up other people's work.
4. **Small commits with clear messages:** `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`.
5. **Not ready? Say so.** Open the pull request as a draft or add the `hold` label.
   Take the label off when it is ready.
6. **Green checks are the bar.** If `guards` or `test` fail, fix the cause. Never weaken a test
   or a check to get a green result.

## What you must never do

- **Never change the gate files** (`.github/`, `CODEOWNERS`, `scripts/ci/`, `.node-version`)
  unless the task explicitly says so. Even then, a code owner must review it, and it
  never auto-merges.
- **Never commit secrets.** No `.env` files, keys, tokens or passwords. Put placeholder names
  in `.env.example`. If a secret was ever committed, tell a maintainer: it must be rotated,
  and deleting the file is not enough.
- **Never add a dependency from outside the normal package registry** (no git URLs, tarballs
  or local paths) without a maintainer's review.
- **Never force-push** a branch someone else is also working on.
- **Never merge your own change to the gate files**, and never approve your own pull request.
- **Never run scheduled or bulk merges.** Merges happen one pull request at a time, when its
  checks are green.

## GitHub access

- Agents never hold a GitHub credential of their own. The organisation's GitHub App acts for
  them through the automation tools, with a short-lived token per step that no agent sees.
- Never paste a token into chat, a file, a command line or `.git/config`. Never use a person's token.

## Releases

- Merged changes go to the **test** server first. If its health check fails, it rolls back
  on its own.
- **Production** only changes through the automation's release step: one exact, already-tested
  version, approved in the Control Room by a person, used once. Nobody promotes by hand.
