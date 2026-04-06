# Feature Scoping — Stage 2

## Purpose

Decompose a Requirement into one or more well-formed Feature issues.
Design any UX/UI impact now — not during implementation.

## When to Run

After at least one Requirement issue has been moved to `backlog` status.
Run this before Feature Design — you cannot design what has not been scoped.

## How to Start

Open Goose and select the **Feature Scoping (Stage 2)** recipe.

## Requirement Label Transitions

During a scoping session, the agent manages the parent requirement's lifecycle labels:

1. **Session start** (after loading the requirement): removes `backlog`, applies `scoping`
2. **Session end** (after all features created and `in-design` applied): removes `scoping`, applies `scheduled`

The full requirement label lifecycle: **Backlog → Scoping → Scheduled → Done**

## What the Agent Does

1. Prints: `=== Feature Scoping Session (Phase 2) — Started ===`
2. Lists available requirements in `backlog` state
3. Waits for the human to select a requirement
4. Transitions the requirement from `backlog` to `scoping`
5. Works through seven artefacts to define the feature:
   - Raw idea summary
   - Problem statement
   - Feature definition — includes a user story statement in `As a [user], I want [goal], so that [benefit]` format
   - MVP scope
   - **Parallel/serial checkpoint** — asks whether all parts can be built independently or must be sequenced. Independent work → multiple features (parallel). Sequential work → one feature with ordered tasks (same branch, same PR). Never creates multiple features with implied serial dependencies.
   - Acceptance criteria (checkboxes, outcome-based)
   - UX design (if applicable)
   - Parking lot review
6. Verifies user story is present and complete before creating the issue
7. Creates Feature issues in the domain repo with `feature` + `backlog` labels
8. Wires sub-issue relationship: Feature → parent Requirement
9. Applies `in-design` to features that are ready to proceed. For features held due to
   cross-repo dependencies, leave at `backlog` and document the dependency in the issue.
10. Transitions the requirement from `scoping` to `scheduled`
11. Prints one of the following exit summaries:

    **All features triggered:**
    ```
    === Feature Scoping Session (Phase 2) — Completed ===
    Features triggered for design: #N, #N
    Automation running — no action needed yet.
    ```

    **Some features held:**
    ```
    === Feature Scoping Session (Phase 2) — Completed ===
    Features triggered for design: #N
    Features held (dependency): #N — waiting for <feature/PR reference> to merge first.
    ```

    **No features triggered (all held):**
    ```
    === Feature Scoping Session (Phase 2) — Completed ===
    No features triggered. All features are held pending dependencies — see issue(s) for details.
    ```

## Outputs

- One or more Feature issues in the domain repo, each containing:
  - `## User Story` section with `As a / I want / so that` structure
  - `## Context` with background and motivation
  - `## Scope` and `## Out of Scope` sections
  - `## Acceptance Criteria` with checkboxes (`- [ ]` format)
  - `## UX Design` (if applicable) with ASCII mockups, flow, error states
  - `## Parent Requirement` linking back to the originating requirement
- `in-design` label applied — triggers automatic Feature Design Session
- Parent requirement transitioned from `scoping` to `scheduled`

## Rules

- Serial vs parallel decomposition: independent capabilities → separate features; sequential capabilities → one feature with ordered tasks; never create multiple features with implied serial dependencies
- Push toward MVP — smallest version that delivers real value
- User story format is mandatory — every feature issue must include `As a / I want / so that`
- Acceptance criteria must use checkbox format (`- [ ]`) and be outcome-based
- UX design must be done now, not deferred to implementation
- Never accept solution criteria — convert to outcome criteria
- If an idea is out of scope, capture it in the parking lot
- Apply `in-design` only when the human confirms the feature is ready

## Notification

The exit summary (see step 11 above) serves as the session notification. No separate notification needed.

## Next Step

The Feature Design Session triggers automatically when `in-design` is applied.
