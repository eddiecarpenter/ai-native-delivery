# Feature Scoping — Stage 2

## Purpose

Decompose a Requirement into one or more well-formed Feature issues.
Design any UX/UI impact now — not during implementation.

Scoping is a mandatory phase — it produces the Feature issue artefact that design depends on.
This session is used when scoping was not completed inline during the Requirements Session.

## When to Run

When a Requirement issue is in `backlog` state and scoping was not completed inline.
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

     **Three-dimensional cost principle** — before recommending parallel features, weigh:
     - **Token cost**: each parallel feature requires its own full Design + Dev session
     - **Build cost**: more branches = more CI runs = more build minutes
     - **Time overhead**: parallel features require coordination and merge ordering

     If the combined work fits comfortably in a single dev session, recommend one feature
     with ordered tasks and explain the cost of splitting. Only recommend parallel features
     when the work is substantial enough that parallelism delivers real value. Record the
     recommendation and reasoning in the scoping summary.
   - Acceptance criteria — use Given/When/Then format for every criterion (not checkboxes, not prose). Minimum three criteria: one success case, one failure case, and at least one edge case.
   - UX design (if applicable)
   - **Deployment strategy** — ask: *"How should this feature reach users once deployed?"*
     Present the options and confirm the type:
     - **No switch** — deployed and immediately live (appropriate for bug fixes, MVP phase, or infrastructure changes)
     - **Feature switch** — hidden until a release decision is made (default for features and enhancements)
       - Confirm mode: `permanent disable` (code must not execute — use when work may be incomplete or breaking) or `toggle` (access control only — use when code is safe but release is pending)
       - Agree on flag name
       - Note: switch removal is a follow-up requirement after full rollout
     - **Functionality switch** — permanent, gated by licence or tier (enters pipeline as a requirement in its own right)
     - **Preview switch** — user opt-in to a new experience while old version remains (enters pipeline as a requirement in its own right)

     If the human elects no switch for a feature or enhancement, ask for the reason and record it.
     See `base/concepts/feature-switches.md` for the full taxonomy.
   - Parking lot review
6. **Impact delta on rejection or modification** — when the human rejects or modifies
   a proposed feature after others have already been accepted:
   - Re-evaluate all previously accepted features: does this rejection or change affect
     their scope, dependencies, or ordering?
   - Surface only features flagged as affected and ask the human to re-confirm them
   - Features not flagged are not re-presented — they remain accepted as-is
7. Verifies user story is present and complete before creating the issue
8. Creates Feature issues in the domain repo with `feature` + `backlog` labels
9. Wires sub-issue relationship: Feature → parent Requirement
10. **Explicit trigger confirmation** — presents the full list of agreed features and asks:
    *"Which of these features should be triggered for design now? (list numbers, or 'all')"*
    - Apply `in-design` only to features the human explicitly selects
    - Features not selected remain at `backlog` with a note in the issue body:
      `> Not triggered during scoping — awaiting human decision.`
    - For features held due to cross-repo dependencies, leave at `backlog` and document
      the dependency in the issue
11. Transitions the requirement from `scoping` to `scheduled`
12. Prints one of the following exit summaries:

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

- One or more Feature issues in the domain repo, each written using the `capture-feature.md` template
- `in-design` label applied — triggers automatic Feature Design Session
- Parent requirement transitioned from `scoping` to `scheduled`

## Rules

- Serial vs parallel decomposition: independent capabilities → separate features; sequential capabilities → one feature with ordered tasks; never create multiple features with implied serial dependencies
- **Three-dimensional cost principle**: before recommending parallel features, weigh token cost, build cost, and time overhead against the parallelism benefit. Batch small independent changes into one feature with ordered tasks unless the work is substantial enough that parallelism delivers real value.
- Push toward MVP — smallest version that delivers real value
- Feature issue structure and format is defined by `capture-feature.md` — follow it exactly
- Acceptance criteria must use Given/When/Then format — not checkboxes, not prose
- UX design must be done now, not deferred to implementation
- Never accept solution criteria — convert to outcome criteria
- If an idea is out of scope, capture it in the parking lot
- **Explicit trigger confirmation**: never apply `in-design` automatically to all agreed features. Present the list and apply only to features the human explicitly selects. Features not selected remain at `backlog`.
- **Impact delta on changes**: when the human rejects or modifies a feature, re-evaluate previously accepted features for impact and re-confirm only those affected

## Notification

The exit summary (see step 11 above) serves as the session notification. No separate notification needed.

## Next Step

The Feature Design Session triggers automatically when `in-design` is applied.
