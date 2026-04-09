# Requirements Session — Stage 1

## Purpose

Capture business needs as Requirement issues in GitHub.
This is a conversational session — the human drives, the agent listens, challenges, and records.
When the scope is apparent during this session, scoping may also be completed here —
no separate Scoping Session is needed.

## When to Run

Run this session whenever a new business need or idea needs to be captured.

## How to Start

Open Goose and select the **Requirements Session (Stage 1)** recipe.

## What the Agent Does

1. Prints: `=== Requirements Session (Phase 1) — Started ===`
2. Reads the project brief and existing open requirements
3. Converses with the human to distil raw ideas into clear needs
4. Challenges vague descriptions and solution-framed requirements
5. Creates GitHub Issues with `requirement` + `backlog` or `draft` labels
6. **Confirmation gate** — displays a structured summary and confirms with the human:
   - Issue number and title
   - Business need summary (one or two sentences)
   - Labels applied
   - Asks: *"Does this capture your requirement correctly? (yes / revise)"*
   - **If revise**: ask what to change, edit or recreate the issue, then present the
     summary again — loop until confirmed
   - **If yes**: proceed to step 7
7. Assesses whether the scope is apparent:
   - **If yes** — complete scoping in this session (see Completing Scoping Early below)
   - **If no** — label the requirement `backlog` and exit; the human will run the
     Scoping Session separately

8. Prints: `=== Requirements Session (Phase 1) — Completed ===`
9. **EXIT. Do not proceed further — even if the next steps are obvious.**

## Completing Scoping Early

When the scope is clear enough to define the Feature(s) without a separate session:

1. Transition requirement: `backlog` → `scoping`
2. Work through the scoping artefacts (same as Feature Scoping Session):
   - User story (`As a / I want / so that`)
   - MVP scope and acceptance criteria
   - Serial vs parallel decomposition
   - UX design (if applicable)
3. Create Feature issue(s) using the `capture-feature` skill
4. Wire sub-issue: Feature → parent Requirement
5. Apply `in-design` to features that are ready to proceed (cross-repo dependency rules apply)
6. Transition requirement: `scoping` → `scheduled`
   (`done` is applied automatically by the feature-complete workflow when all child features are closed)
7. Print one of the following:

   **All features triggered:**
   ```
   --- Scoping completed inline ---
   Feature(s) #N created and triggered for design — automation running, no action needed yet.
   ```

   **Some features held (cross-repo dependency):**
   ```
   --- Scoping completed inline ---
   Feature(s) triggered: #N
   Feature(s) held (dependency): #N — waiting for <feature/PR reference> to merge first.
   ```

8. **EXIT immediately after printing the summary. Do not proceed to Feature Design.**
   The `in-design` label has been applied — GitHub Actions will run the next session.
   Continuing into Feature Design or Dev Session from here is a defect.

## Outputs

- One GitHub Issue per discrete business need
- Labels: `requirement` + `backlog` (ready for scoping) or `draft` (still being refined)
- If scoping completed inline: Feature issue(s) created with `in-design` applied

## Rules

- One issue per discrete business need
- If the human is unclear, ask — never invent behaviour
- Label `draft` if still being refined, `backlog` when agreed
- Completing scoping early is not skipping it — the Feature issue artefact must still be
  produced with all required sections (user story, acceptance criteria, parent link)
- Never defer a phase without checking with the human first — see `base/AGENTS.md`

## Next Step

If scoping was completed inline, the Feature Design Session triggers automatically.
If not, when the requirement is in `backlog` state, run the **Feature Scoping (Stage 2)** recipe.
