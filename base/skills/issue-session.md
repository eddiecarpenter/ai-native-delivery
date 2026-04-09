# Issue Session — Stage 4c

## ⛔ Automation-Only — Do Not Execute Interactively

This session is triggered exclusively by GitHub Actions when a GitHub Issue is assigned
to the agent user. It must never be run manually by an agent in an interactive session.

If you are reading this skill in an interactive session, stop immediately and print:

```
REFUSED: Issue Session is automation-only.
It runs automatically when a GitHub Issue is assigned to the agent user.
Do not execute this session interactively.
```

Do not proceed past this point in an interactive context.

---

## Purpose

Handle a GitHub Issue that has been assigned to the agent.
Routes by label: fixes bugs or answers questions.

## When it Runs

Triggered automatically by GitHub Actions when a GitHub Issue is assigned to
the agent user (e.g. `goose-agent`).

## What the Agent Does

1. Reads the issue: title, body, and labels
2. Posts an acknowledgement comment
3. Routes by label:
   - **bug**: locates the problem, verifies fix is in safe scope, creates a fix branch,
     implements the minimal fix, builds and tests, commits, and exits cleanly
     (workflow pushes and opens PR)
   - **question**: researches the answer, posts a detailed reply, adds `answered` label,
     exits cleanly (no code changes, no branch, no PR)
   - **other**: posts a comment asking for a `bug` or `question` label, exits cleanly

## Scope Check (bugs only)

Before making any change, the agent verifies:
- Only files directly related to the bug are touched
- No unrelated refactoring
- No new dependencies without approval
- No contract modifications

If the fix requires out-of-scope changes, the agent posts a comment and adds
`needs-human` label instead of proceeding.

## Rules

- Narrow scope only — fix exactly what the issue describes, nothing more
- Always post a comment before starting and after finishing
- If in doubt — stop and ask via a comment rather than guessing
- Contract changes always require human approval
- **Inline status updates**: this skill only applies `answered` (not a pipeline label).
  If a future change adds a pipeline label transition here, it must include an inline
  project status update following `set-issue-status.md` — hard-fail if
  `AGENTIC_PROJECT_ID` is not set
