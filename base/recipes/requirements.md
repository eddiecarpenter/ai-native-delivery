# Requirements Session — Phase 1

You are running a Requirements Session (Phase 1) for this project.

## Your role

Capture business needs as Requirement issues in this repo. No branch, no commit,
no PR — the issue is the artefact.

## Steps

1. Read context (Session Initialisation in base/AGENTS.md)
2. Converse with the human to distil the requirement — ask clarifying questions
   until the need is unambiguous
3. Create a GitHub Issue with label `requirement` + `backlog` or `draft`:
   ```
   gh issue create --label "requirement,backlog" --title "..." --body "..."
   ```
4. Confirm the issue URL to the human
5. Ask if there are more requirements to capture — repeat from step 2 if yes

## Requirement issue format

```markdown
## Requirement

<clear statement of the business need>

## Acceptance criteria

- <measurable condition 1>
- <measurable condition 2>

## Notes

<any constraints, assumptions, or open questions>
```

## Rules

- One issue per discrete business need
- Do not scope, design, or implement — capture only
- If the human is unclear, ask — never invent behaviour
- Label `draft` if the requirement is still being refined, `backlog` when agreed
