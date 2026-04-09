# Foreground Recovery

## Purpose

The **Foreground Recovery** session is the emergency escape hatch for any situation the
automated pipeline cannot handle on its own — not just workflow failures. When something
unexpected happens, this is the correct response. The protocol evolves as new failure
modes are discovered and handled here.

When used for a workflow failure: diagnose and fix the issue on the current feature
branch. Fix only what is failing — do not expand scope.

## When to Run

Any time the automated pipeline is blocked or in an unrecoverable state, including:
- Build is red
- Tests are failing
- Merge conflict on the feature branch
- Workflow never triggered (silent failure)
- Any other situation requiring manual intervention

## How to Start

Open Goose and select the **Foreground Recovery** recipe.

## What the Agent Does

1. Reads project context and confirms current branch (never works on main)
2. Queries open Task sub-issues on the Feature before touching any code
3. Asks the human for the exact error output — never guesses the cause
4. Diagnoses the root cause from the exact error
5. Fixes only what is failing — does not refactor surrounding code
6. Builds and tests
7. Commits, closes the Task issue if complete, and pushes
8. Re-triggers the Dev Session workflow if needed
9. Reports exactly what was fixed

## Rewind Paths

When a simple fix is not enough, a **rewind** may be needed — rolling back to a previous
pipeline phase and re-running from there. The agent recommends a rewind level but **must
obtain explicit human confirmation before executing any cleanup**.

| Rewind Level | Trigger |
|---|---|
| Dev Session only | Failing tests or build error on the current branch |
| Feature Design | Tasks are wrong — need to redesign without re-scoping |
| Scoping | Acceptance criteria are wrong — need to re-scope without re-capturing requirements |
| Requirements | Business need is misunderstood — start over from requirements |
| Full reset | Fundamental misalignment — archive issue, start fresh |

### Dev Session only

- **Cleanup**: fix the failing code on the feature branch, re-run build and tests
- **Commands**: standard fix-and-commit flow (no branch or issue cleanup needed)
- **Confirmation**: `"This rewind will fix and re-commit on the current branch. Confirm? (yes/no)"`

### Feature Design

- **Cleanup**: close existing task issues, delete the feature branch, remove `in-development` label, re-apply `in-design`
- **Commands**:
  ```bash
  gh issue list --label task --state open --json number --jq '.[].number' | xargs -I{} gh issue close {}
  git push origin --delete feature/<N>-<description>
  gh issue edit <feature-number> --remove-label in-development --add-label in-design
  ```
- **Confirmation**: `"This rewind will close all open tasks, delete the feature branch, and re-trigger design. Confirm? (yes/no)"`

### Scoping

- **Cleanup**: close the feature issue, delete the feature branch, remove `scheduled` from the requirement, re-apply `backlog`
- **Commands**:
  ```bash
  gh issue close <feature-number>
  git push origin --delete feature/<N>-<description>
  gh issue edit <requirement-number> --remove-label scheduled --add-label backlog
  ```
- **Confirmation**: `"This rewind will close the feature issue, delete the branch, and return the requirement to backlog for re-scoping. Confirm? (yes/no)"`

### Requirements

- **Cleanup**: close the feature issue and requirement issue, delete the feature branch
- **Commands**:
  ```bash
  gh issue close <feature-number>
  gh issue close <requirement-number>
  git push origin --delete feature/<N>-<description>
  ```
- **Confirmation**: `"This rewind will close both the feature and requirement issues and delete the branch. You will need to re-capture requirements from scratch. Confirm? (yes/no)"`

### Full reset

- **Cleanup**: close all related issues (requirement, feature, tasks), delete the feature branch, archive if needed
- **Commands**:
  ```bash
  gh issue list --label task --state open --json number --jq '.[].number' | xargs -I{} gh issue close {}
  gh issue close <feature-number>
  gh issue close <requirement-number>
  git push origin --delete feature/<N>-<description>
  ```
- **Confirmation**: `"This is a full reset — all related issues will be closed and the branch deleted. Start completely fresh. Confirm? (yes/no)"`

**The agent must never execute any rewind cleanup without the human explicitly saying "yes".**

## Rules

- Never expand scope beyond the failing issue
- Never guess — always diagnose from exact error output
- Never make changes on main
- If the fix requires a contract change or broad refactor, stop and raise it with the human
- If the workflow does not auto-restart after the push, apply `in-development` label again
- **Rewinds require explicit human confirmation** — never execute cleanup commands without a "yes"

## Notification

After pushing the fix, notify the user: "Fix pushed for Feature #N — please confirm the Dev Session workflow has restarted."

## Next Step

Once the fix is pushed, the Dev Session workflow re-triggers automatically.
If it does not, re-apply the `in-development` label manually.
