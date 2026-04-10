# Dev Session — Stage 4

## ⛔ Automation-Only — Do Not Execute Interactively

This session is triggered exclusively by GitHub Actions when a Feature issue receives
the `in-development` label. It must never be run manually by an agent in an interactive session.

If you are reading this skill in an interactive session, stop immediately and print:

```
REFUSED: Dev Session is automation-only.
It runs automatically when in-development is applied.
Do not execute this session interactively.
```

Do not proceed past this point in an interactive context.

---

## Purpose

Implement all open Task sub-issues on the feature branch, in order.

## When it Runs

Triggered automatically by GitHub Actions when a Feature issue is labelled `in-development`.

## What the Agent Does

1. Verifies it is on the correct feature branch — never works on main
2. Reads the Feature issue and extracts acceptance criteria for end-of-session verification
3. Queries open Task sub-issues on the Feature, ordered by issue number
4. For each Task in order:
   - Reads the task issue and understands what must be built
   - Implements the work described
   - Builds and tests — stops immediately on failure and reports the exact error
   - Commits: `feat: [task description] — task N of N (#feature-issue)`
   - Closes the task issue
5. Verifies each acceptance criterion has test coverage — stops if any criterion is uncovered
6. When all tasks are closed and criteria verified — prints: `=== Dev Session — Completed ===`
7. Exits cleanly — the workflow pushes and opens the PR automatically

## Rules

- Never commit on main
- Never skip a failing test — fix it before moving to the next task
- Never claim a task complete without running build and tests
- A feature is not complete until all acceptance criteria have test coverage
- Report exact command output on any failure
- Follow the standards in `.ai/standards/<stack>.md` exactly
- **Inline status updates**: this skill does not apply pipeline labels (the workflow
  applies `in-review`). If a future change adds a pipeline label transition here, it
  must include an inline project status update following `set-issue-status.md` —
  hard-fail if `AGENTIC_PROJECT_ID` is not set

## Notification

Before exiting, notify the user: "PR #N is ready for your review."

## Next Step

The workflow pushes the branch and opens a PR with `Closes #N`.
Human review happens in the PR. If review comments need addressing, the
**PR Review Session (Stage 4b)** recipe handles that.
