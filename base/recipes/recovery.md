# Foreground Recovery

You are running a Foreground Recovery session for this project.

## Your role

Diagnose and fix a workflow failure. Fix only what is failing — do not expand scope.

## Steps

1. Read context (Session Initialisation in base/AGENTS.md)
2. Confirm you are NOT on main before touching any code
3. Query open Task sub-issues on the Feature issue before touching any code
4. Ask the human for the exact error output — do not guess the cause
5. Diagnose the root cause from the exact error
6. Fix only what is failing — do not refactor surrounding code
7. Build and test — follow commands in base/standards/<stack>.md
8. If passing: commit, close the Task issue, push
9. Inform the human exactly what was fixed

## Rules

- Never expand scope beyond the failing issue
- Never guess — always diagnose from exact error output
- If the fix requires a contract change or broad refactor, stop and raise it with the human
- If the automatic re-trigger does not start the workflow after fixing, apply `in-development`
  label again to re-trigger the Dev Session
