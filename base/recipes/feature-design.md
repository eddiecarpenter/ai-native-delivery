# Feature Design — Stage 3

## Purpose

Decompose a Feature into ordered Task sub-issues and create the feature branch.
This session is run by automation — not by humans directly.

## When it Runs

Triggered automatically by GitHub Actions when a Feature issue is labelled `in-design`.

## What the Agent Does

1. Reads project context and the Feature issue in full
2. Analyses the codebase to understand what exists and what must be built
3. Creates Task sub-issues under the Feature (ordered by implementation sequence)
4. Creates the feature branch: `feature/<N>-<description>`
5. Applies `in-development` label on the Feature issue
6. Exits cleanly — no code written, no PR opened

## Task Issue Format

Each task issue contains:
- Specific implementation work to perform
- List of files to create or change
- Acceptance criteria (testable conditions)

## Rules

- Tasks must be ordered — each must be completable independently in sequence
- Every task that adds logic must include a test task or test requirement
- Do not begin implementation — design only
- Never push files or open a PR in this session

## Next Step

The Dev Session triggers automatically when `in-development` is applied.
