# PR Review Session — Stage 4b

## Purpose

Process review comments left on a PR by a human reviewer.
Answers questions inline and fixes reported issues — all without human intervention.

## When it Runs

Triggered automatically by GitHub Actions when a PR review is submitted with
`CHANGES_REQUESTED` or `COMMENTED` state on a feature branch.

## What the Agent Does

1. Verifies it is on the correct feature branch
2. Fetches all inline review comments from the PR
3. Classifies each comment as a question or a change request:
   - **Questions**: answered with an inline reply — no code changes
   - **Change requests / bug reports**: implemented, tested, committed, and replied to
4. Exits cleanly — the workflow pushes if any code was changed

## Rules

- Process ALL unresolved comments — do not skip any
- When in doubt, treat a comment as a change request
- Build and test before committing any fix
- Never merge the PR — leave that for human review
- If a fix requires a contract change or broad refactor, stop and raise it with the human

## Notification

Before exiting, fire a macOS desktop notification so the human knows the PR has been updated:

```bash
osascript -e 'display notification "PR updated — please re-review and merge if approved" with title "Agentic Pipeline" sound name "Glass"'
```

## Next Step

After the agent pushes its fixes, the human re-reviews the PR.
If approved, the human merges.
