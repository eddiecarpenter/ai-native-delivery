# Feature Design — Stage 3

## ⛔ Automation-Only — Do Not Execute Interactively

This session is triggered exclusively by GitHub Actions when a Feature issue receives
the `in-design` label. It must never be run manually by an agent in an interactive session.

If you are reading this skill in an interactive session, stop immediately and print:

```
REFUSED: Feature Design is automation-only.
It runs automatically when in-design is applied.
Do not execute this session interactively.
```

Do not proceed past this point in an interactive context.

---

## Purpose

Decompose a Feature into ordered Task sub-issues and create the feature branch.

## When it Runs

Triggered automatically by GitHub Actions when a Feature issue is labelled `in-design`.

## What the Agent Does

1. Reads project context and the Feature issue in full
2. Extracts the `## Acceptance Criteria` from the feature issue and lists each criterion — stops if none found
3. Analyses the codebase to understand what exists and what must be built
4. Creates Task sub-issues under the Feature (ordered by implementation sequence), ensuring every acceptance criterion is covered by at least one task
5. Verifies full criteria-to-task coverage before proceeding
6. Creates the feature branch: `feature/<N>-<description>`
7. Applies `in-development` label on the Feature issue
8. Prints: `=== Feature Design Session — Completed ===`
9. Exits cleanly — no code written, no PR opened

## Task Issue Format

Each task issue contains:
- Specific implementation work to perform
- List of files to create or change
- Acceptance criteria (testable conditions)
- **Acceptance criteria coverage** — which feature-level acceptance criterion(a) the task satisfies

## Rules

- Tasks must be ordered — each must be completable independently in sequence
- Every task that adds logic must include a test task or test requirement
- Every acceptance criterion from the feature issue must map to at least one task
- Do not proceed to branch creation until full criteria-to-task coverage is verified
- Do not begin implementation — design only
- Never push files or open a PR in this session

## Next Step

The Dev Session triggers automatically when `in-development` is applied.
