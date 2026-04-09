# PR Review Session — Stage 4b

## ⛔ Automation-Only — Do Not Execute Interactively

This session is triggered exclusively by GitHub Actions when a PR review is submitted.
It must never be run manually by an agent in an interactive session.

If you are reading this skill in an interactive session, stop immediately and print:

```
REFUSED: PR Review Session is automation-only.
It runs automatically when a PR review is submitted.
Do not execute this session interactively.
```

Do not proceed past this point in an interactive context.

---

## Purpose

Process review comments left on a PR by a human reviewer.
Answers questions inline and fixes reported issues — all without human intervention.

## When it Runs

Triggered automatically by GitHub Actions when a PR review is submitted with
`CHANGES_REQUESTED` or `COMMENTED` state on a feature branch.

## What the Agent Does

1. Verifies it is on the correct feature branch
2. Fetches all inline review comments from the PR
3. Classifies each comment into one of three categories:
   - **Questions**: answered with an inline reply — no code changes
   - **Change requests / bug reports**: implemented, tested, committed, and replied to
   - **Ambiguous or scope-changing feedback**: when the agent cannot resolve the comment
     with a simple fix (e.g. the fix requires a contract change, broad refactor, or the
     intent is unclear):
     1. Posts a GitHub comment explaining what it cannot resolve and why
     2. Applies the `needs-foreground-review` label to the PR
     3. Exits immediately without making any code changes
4. Exits cleanly — the workflow pushes if any code was changed

## Rules

- Process ALL unresolved comments — do not skip any
- When in doubt, treat a comment as a change request
- Build and test before committing any fix
- Never merge the PR — leave that for human review
- If a fix requires a contract change or broad refactor, escalate: post a comment, apply `needs-foreground-review`, and exit without changes
- When feedback is ambiguous or scope-changing and cannot be resolved with a simple fix, always escalate rather than guessing

## Notification

Before exiting, notify the user: "PR #N has been updated — please re-review and merge if approved."

## Next Step

After the agent pushes its fixes, the human re-reviews the PR.
If approved, the human merges.
