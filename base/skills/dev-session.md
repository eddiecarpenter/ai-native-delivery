# Dev Session — Stage 4

## Purpose

Implement all open Task sub-issues on the feature branch, in order.
This session is run by automation — not by humans directly.

## When it Runs

Triggered automatically by GitHub Actions when a Feature issue is labelled `in-development`.

## What the Agent Does

1. Verifies it is on the correct feature branch — never works on main
2. Queries open Task sub-issues on the Feature, ordered by issue number
3. For each Task in order:
   - Reads the task issue and understands what must be built
   - Implements the work described
   - Builds and tests — stops immediately on failure and reports the exact error
   - Commits: `feat: [task description] — task N of N (#feature-issue)`
   - Closes the task issue
4. When all tasks are closed — exits cleanly
5. The workflow pushes and opens the PR automatically

## Rules

- Never commit on main
- Never skip a failing test — fix it before moving to the next task
- Never claim a task complete without running build and tests
- Report exact command output on any failure
- Follow the standards in `base/standards/<stack>.md` exactly

## Notification

Before exiting, fire a macOS desktop notification so the human knows the PR is ready:

```bash
osascript -e 'display notification "PR ready for review — please check GitHub" with title "Agentic Pipeline" sound name "Glass"'
```

## Next Step

The workflow pushes the branch and opens a PR with `Closes #N`.
Human review happens in the PR. If review comments need addressing, the
**PR Review Session (Stage 4b)** recipe handles that.
