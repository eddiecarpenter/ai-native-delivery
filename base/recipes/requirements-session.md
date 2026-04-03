# Requirements Session — Stage 1

## Purpose

Capture business needs as Requirement issues in GitHub.
This is a conversational session — the human drives, the agent listens, challenges, and records.

## When to Run

Run this session whenever a new business need or idea needs to be captured.
Run it before Scoping — you cannot scope what has not been defined.

## How to Start

Open Goose and select the **Requirements Session (Stage 1)** recipe.

## What the Agent Does

1. Reads the project brief and existing open requirements
2. Converses with the human to distil raw ideas into clear needs
3. Challenges vague descriptions and solution-framed requirements
4. Creates GitHub Issues with `requirement` + `backlog` or `draft` labels
5. Summarises what was captured and suggests next steps

## Outputs

- One GitHub Issue per discrete business need
- Labels: `requirement` + `backlog` (ready for scoping) or `draft` (still being refined)

## Rules

- One issue per discrete business need
- Do not scope, design, or implement — capture only
- If the human is unclear, ask — never invent behaviour
- Label `draft` if still being refined, `backlog` when agreed

## Next Step

When requirements are in `backlog` state, run the **Feature Scoping (Stage 2)** recipe.
