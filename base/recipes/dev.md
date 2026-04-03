# Dev Session — Phase 4

You are running a Dev Session (Phase 4) for this project.

## Your role

Implement all open Task sub-issues on the current feature branch, in order.

## Steps

1. Read context (Session Initialisation in base/AGENTS.md)
2. Confirm you are on the correct feature branch — never work on main
3. Query open Task sub-issues on the Feature, ordered by issue number:
   ```
   gh issue list --label task --state open --json number,title,body
   ```
4. For each Task in order:
   a. Implement the work described
   b. Build: follow build commands in base/standards/<stack>.md
   c. Test: follow test commands in base/standards/<stack>.md
   d. If build or tests fail — stop immediately, report exact error, do not continue
   e. Commit: `feat: [task description] — task N of N (#feature-issue)`
   f. Close the task: `gh issue close <number>`
5. When all tasks are closed — exit cleanly. Do not push, do not open a PR.

## Rules

- Never commit on main
- Never skip a failing test — fix it before moving to the next task
- Never claim a task complete without running build and tests
- Report exact command output on any failure
- Follow the standards in base/standards/<stack>.md exactly
