# Capture Feature — Issue Body Template

## Purpose

Defines the canonical structure for Feature issues created during Scoping Sessions (Phase 2).
Apply this skill when writing the body of every Feature issue.

## Template

```markdown
## User Story

As a <role>, I want <goal>, so that <benefit>.

## Context

Background and motivation for this feature. Why does it exist? What problem does it solve?
Link to relevant prior decisions or related issues if helpful.

## Scope

What this feature covers. Be specific — this is the implementation boundary.

## Out of Scope

What is explicitly not included. Prevents scope creep and clarifies intent.

## Acceptance Criteria

Each criterion is a Given/When/Then scenario. Cover at minimum:
- One success case
- One failure case
- At least one edge case

- **Given** <precondition>,
  **when** <action>,
  **then** <expected outcome>

- **Given** <precondition>,
  **when** <action fails or input is invalid>,
  **then** <expected failure behaviour>

- **Given** <edge-case precondition>,
  **when** <action>,
  **then** <expected edge-case outcome>

## Deployment Strategy

How this feature reaches users. One of:

- **No switch** — deployed and immediately live (bug fixes, or human-approved exception)
- **Feature switch** — hidden behind a switch until release decision is made
  - Mode: `permanent disable` (code must not execute) or `toggle` (access control only)
  - Flag name: `<flag-name>`
  - Exit condition: remove switch after full rollout — tracked as a follow-up requirement
- **Functionality switch** — permanent, gated by licence or tier
  - Flag name: `<flag-name>`
- **Preview switch** — user opt-in to a new experience while old version remains available
  - Flag name: `<flag-name>`
  - Exit condition: remove when old version is retired

If no switch: state the reason (e.g. bug fix, MVP phase, infrastructure change).

See `base/concepts/feature-switches.md` for the full taxonomy.

## UX Design

ASCII mockups, user flow, error states, and edge-case UI behaviour.
Omit this section for non-UI features.

## Notes

Implementation constraints, API choices, or technical context known at scoping time.
Keep this separate from acceptance criteria — criteria define outcomes, notes capture context.
Omit this section if there is nothing to note.

## Parent Requirement

Closes part of #<requirement>
```

Use `Closes #<requirement>` instead of `Closes part of` when the requirement produces only a single feature.

**Federated topology:** if the feature lives in a domain repo and the requirement lives
in the agentic (control plane) repo, use the full cross-repo reference format:

```
Closes part of owner/agentic-repo#<requirement>
```

This is required so the `feature-complete` workflow can locate and auto-close the parent
requirement across repos. Using `#N` alone in a domain repo refers to an issue in that
same repo, not the agentic repo.

## Rules

- User Story is mandatory — every feature issue must include one
- Acceptance criteria must use Given/When/Then format — not checkboxes, not prose
- Minimum three criteria: success, failure, edge case — add more as needed
- Context, Scope, and Out of Scope are mandatory — define the boundary explicitly
- Deployment Strategy is mandatory — every feature issue must state how it reaches users
- Features and enhancements default to a feature switch — record the switch type, mode, flag name, and exit condition
- If the human waives the switch, record the reason explicitly
- UX Design is mandatory for any feature with user-facing changes — do it now, not during implementation
- Notes capture implementation context — never mix implementation detail into acceptance criteria
- Parent Requirement link is mandatory — every feature traces back to a requirement
- In federated topology, always use the full `owner/repo#N` format for the parent link
