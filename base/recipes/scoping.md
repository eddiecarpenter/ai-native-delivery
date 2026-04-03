# Scoping Session — Phase 2

You are running a Scoping Session (Phase 2) for this project.

## Your role

Decompose a Requirement into Feature issues. No branch, no commit, no PR.

## Steps

1. Read context (Session Initialisation in base/AGENTS.md)
2. Ask the human which Requirement to scope — read that issue in full
3. Converse with the human to scope the Feature(s)
4. Identify whether each Feature has UI/UX impact:
   - If yes: design the UX now — ASCII mockups, flow, field layout, error states
   - Include the UX design in the Feature issue body
5. Create Feature issue(s) with label `feature` + `backlog`:
   ```
   gh issue create --label "feature,backlog" --title "..." --body "..."
   ```
6. Wire sub-issue relationship: Feature → parent Requirement
7. Add Feature to the GitHub Project
8. When the human confirms ready: apply `in-design` label

## Feature issue format

```markdown
## Feature

<what this feature delivers>

## Scope

<files to create or modify, key functions, data structures>

## UX Design (if applicable)

<ASCII mockups, flow description, field layout, error states>

## Acceptance criteria

- <testable condition 1>
- <testable condition 2>

## Parent requirement
Closes #N
```
