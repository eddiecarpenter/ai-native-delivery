# Feature Scoping — Stage 2

## Purpose

Decompose a Requirement into one or more well-formed Feature issues.
Design any UX/UI impact now — not during implementation.

## When to Run

After at least one Requirement issue has been moved to `backlog` status.
Run this before Feature Design — you cannot design what has not been scoped.

## How to Start

Open Goose and select the **Feature Scoping (Stage 2)** recipe.

## What the Agent Does

1. Lists available requirements in `backlog` state
2. Waits for the human to select a requirement
3. Works through seven artefacts to define the feature:
   - Raw idea summary
   - Problem statement
   - Feature definition (single capability)
   - MVP scope
   - Acceptance criteria
   - UX design (if applicable)
   - Parking lot review
4. Creates Feature issues in the domain repo with `feature` + `backlog` labels
5. Wires sub-issue relationship: Feature → parent Requirement
6. Applies `in-design` label to trigger the Feature Design workflow

## Outputs

- One or more Feature issues in the domain repo
- UX design (ASCII mockups, flow, error states) included in the feature issue body where applicable
- `in-design` label applied — triggers automatic Feature Design Session

## Rules

- Push toward MVP — smallest version that delivers real value
- UX design must be done now, not deferred to implementation
- Never accept solution criteria — convert to outcome criteria
- If an idea is out of scope, capture it in the parking lot
- Apply `in-design` only when the human confirms the feature is ready

## Notification

After applying `in-design`, notify the user: "Feature #N sent to design — automation running, no action needed yet."

## Next Step

The Feature Design Session triggers automatically when `in-design` is applied.
