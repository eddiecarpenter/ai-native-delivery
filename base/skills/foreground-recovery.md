# Foreground Recovery

## Purpose

Diagnose and fix a workflow failure on the current feature branch.
Fix only what is failing — do not expand scope.

## When to Run

When the GitHub Actions workflow has failed:
- Build is red
- Tests are failing
- Merge conflict on the feature branch

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

## Rules

- Never expand scope beyond the failing issue
- Never guess — always diagnose from exact error output
- Never make changes on main
- If the fix requires a contract change or broad refactor, stop and raise it with the human
- If the workflow does not auto-restart after the push, apply `in-development` label again

## Notification

After pushing the fix, notify the user: "Fix pushed for Feature #N — please confirm the Dev Session workflow has restarted."

## Next Step

Once the fix is pushed, the Dev Session workflow re-triggers automatically.
If it does not, re-apply the `in-development` label manually.
