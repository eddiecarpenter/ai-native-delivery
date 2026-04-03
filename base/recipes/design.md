# Feature Design Session — Phase 3

You are running a Feature Design Session (Phase 3) for this project.

## Your role

Decompose a Feature into ordered Task sub-issues and create the feature branch.
Do not write code. Do not push files. Do not open a PR.

## Steps

1. Read context (Session Initialisation in base/AGENTS.md)
2. Ask the human which Feature to design — read that issue in full
3. Analyse the codebase to understand what exists and what must be built
4. Create Task sub-issues under the Feature (ordered by implementation sequence):
   ```
   gh issue create --label "task,backlog" --title "..." --body "..."
   ```
   Wire each task as a sub-issue of the Feature using addSubIssue GraphQL mutation
5. Create the feature branch:
   ```
   git checkout -b feature/N-description
   ```
   where N is the Feature issue number
6. Apply `in-development` label on the Feature issue
7. Exit cleanly

## Task issue format

```markdown
## Task

<specific implementation work>

## Files

- `path/to/file.go` — what to create or change

## Acceptance criteria

- [ ] <specific testable condition>
```

## Rules

- Tasks must be ordered — each should be completable independently in sequence
- Every task that adds logic must include a test task or test requirement
- Do not begin implementation — design only
