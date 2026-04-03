# AGENTS.md — Agent Protocol

This file governs how AI agents behave in this repository and all domain repos.
It is language-agnostic and reusable across projects.

**This file is managed by the `agentic-development` template. Do not edit manually.
Local overrides belong in `AGENTS.local.md`.**

---

## Session Initialisation

At the start of every session, read these sources in order before doing anything else:

1. `docs/PROJECT_BRIEF.md` — what the agentic system is and how it works
2. Read `REPOS.md`. For each repo with status `active`, derive its local directory as
   `<type>s/<name>` (e.g. `type: domain` → `domains/<name>`, `type: tool` → `tools/<name>`).
   For each unique type, ensure the type folder (`<type>s/`) exists — if not:
   a. Create the folder with a `.gitkeep` file
   b. Stage it: `git add <type>s/.gitkeep`
   c. Add `<type>s/*/` to `.gitignore` and stage that too: `git add .gitignore`
   d. Commit both: `chore: bootstrap <type>s/ directory`
   Check whether each `<type>s/<name>` directory exists locally. If any repos are
   missing, list them and ask the user whether to clone them before proceeding.
   Clone command: `git clone <repo> <type>s/<name>`
3. Query open Requirement issues in the agentic repo:
   `gh issue list --repo <agentic-repo> --label requirement --state open --json number,title,labels`
4. For domain sessions — query open Feature issues in the domain repo:
   `gh issue list --label feature --state open --json number,title,labels,body`
5. Read the relevant standards file from `base/standards/` for the domain language
   (e.g. `base/standards/go.md` for Go domains)

Do not skip any step. Do not begin work until all steps are complete.

There is no STATUS.md. Current state is derived from GitHub Issues.

---

## Session Types

### Environment Bootstrap Session (Phase 0a)

Run interactively by a human. Creates a brand new agentic environment from scratch.
This session is run once per project. The output is a fully configured agentic repo
ready for Phase 1.

All pre-flight checks, topology selection, owner/org selection, and project details
are collected by `bootstrap.sh` before the agent is invoked. The agent receives all
confirmed values and executes steps 3-7 only. Do not ask the human for any information
that has already been provided — proceed directly to repo creation.

#### Step 3 — Create the Repo

```bash
gh repo create <owner>/<repo-name> \
  --template eddiecarpenter/agentic-development \
  --private
```

Repo naming:
- Embedded: `<project-name>` — no suffix, this is the project repo
- Organisation: `<project-name>-agentic` — control plane repo

Clone into the working directory provided by bootstrap.sh:
```bash
git clone git@github.com:<owner>/<repo-name>.git <working-dir>/<repo-name>
```

#### Step 4 — Clean Up Template Files

The template includes files that belong only in the template itself.
Remove them from the newly cloned repo:

```bash
cd <working-dir>/<repo-name>
git rm bootstrap.sh bootstrap.sh.md5
git commit -m "chore: remove template bootstrap files"
```

#### Step 5 — Scaffold Project Structure

Read the **Project Initialisation** section of the relevant standards file in `base/standards/`
and follow the instructions there exactly.

| Stack | Standards file |
|---|---|
| Go | `base/standards/go.md` |
| Java / Quarkus | `base/standards/java-quarkus.md` |
| Java / Spring Boot | `base/standards/java-spring.md` |
| TypeScript / Node.js | `base/standards/typescript.md` |
| Python | `base/standards/python.md` |
| Rust | `base/standards/rust.md` |

Commit: `chore: scaffold <stack> project structure`

#### Step 6 — Configure the Repo

Apply standard configuration:

**Branch protection on `main`:**
```bash
gh api repos/<owner>/<repo>/branches/main/protection \
  --method PUT \
  --field required_pull_request_reviews=null \
  --field enforce_admins=false \
  --field restrictions=null \
  --field required_status_checks=null
```

**Standard labels** — create if not present:
`requirement`, `feature`, `task`, `backlog`, `draft`, `in-design`,
`in-development`, `in-review`, `done`

```bash
for label in requirement feature task backlog draft in-design in-development in-review done; do
  gh label create "$label" --repo <owner>/<repo> --force
done
```

**Secrets** — if PAT is needed for workflows:
- Organisation: guide human to add PAT as an org secret in GitHub Settings
- Embedded: guide human to add PAT as a repo secret

#### Step 7 — Populate the Repo

In the cloned repo:
1. Update `REPOS.md` with the project description
2. Update `AGENTS.local.md` with the template source and any project-specific notes:
   ```
   ## Template Source
   Template: eddiecarpenter/agentic-development
   ```
3. Update `README.md` with the project name and description
4. If Antora — scaffold `docs/` AsciiDoc module structure and `antora-playbook.yml`
5. Commit: `chore: bootstrap <project-name>`
6. Push: `git push origin main`

#### Step 8 — Create the GitHub Project

```bash
gh project create --owner <owner> --title "<project-name>"
```

#### Step 9 — Hand Off

Confirm to the human:
- Agentic repo URL
- GitHub Project URL
- Local clone path

For organisation topology: offer to proceed to Repo Inception Session (Phase 0b)
to register the first domain or tool repo.
For embedded topology: offer to proceed to Requirements Session (Phase 1).

---

### Repo Inception Session (Phase 0b)

Run interactively by a human. Adds a new repo (domain, tool, or other type) to an
existing agentic environment. No code is written — the output is a bootstrapped repo
registered in `REPOS.md` and ready for Phase 1.

#### Step 1 — Read Context

Follow Session Initialisation. Confirm the agentic environment is healthy before
proceeding.

#### Step 2 — Repo Questions

Collect the following:
- **Repo type** — domain, tool, or other (determines local clone directory `<type>s/`)
- **Repo name** — follows convention `<name>-<type>` for domains (e.g. `charging-domain`)
  or just `<name>` for tools (e.g. `ocs-testbench`)
- **Description** — one or two sentences, goes into REPOS.md
- **Stack** — drives which `base/standards/` file applies

#### Step 3 — Scoping Conversation

Have a methodology-agnostic scoping conversation with the human to establish:
- What problem does this repo solve?
- What are its boundaries — what is in scope, what is explicitly out of scope?
- How does it relate to other repos in the environment?
- What are the key interfaces or contracts with other systems?

The output of this conversation is captured as the repo's `docs/PROJECT_BRIEF.md`.

#### Step 4 — Create the GitHub Repo

```bash
gh repo create <org>/<repo-name> --private
```

Apply standard configuration:
- Branch protection on `main` (same as Phase 0a Step 4)
- Standard labels
- Link to the org GitHub Project

#### Step 5 — Bootstrap the Repo Structure

Initialise the repo with:
- `CLAUDE.md` — referencing the agentic repo's `base/AGENTS.md`
- `AGENTS.local.md` — placeholder for local overrides
- `docs/PROJECT_BRIEF.md` — output of the scoping conversation (Step 3)
- `README.md` — operational detail (how to run, setup, environment config)
- `.github/workflows/` — thin caller workflows referencing the agentic template

Commit: `chore: bootstrap <repo-name>`

#### Step 6 — Register in REPOS.md

Add the new repo entry to `REPOS.md` in the agentic repo:
```
## <repo-name>

- **Repo:** git@github.com:<org>/<repo-name>.git
- **Stack:** <stack>
- **Type:** <type>
- **Status:** active
- **Description:** <description>
```

Commit and raise a PR to the agentic repo: `chore: register <repo-name> in REPOS.md`

#### Step 7 — Hand Off

- Confirm the repo URL to the human
- Proceed to Requirements Session (Phase 1)

---

### Template Sync Session

Triggered by the human with a natural language instruction such as:
> *"Sync template"* or *"Resync base"*

Runs in the agentic repo root. Updates `base/` from the upstream template.
The human reviews the diff and confirms before anything is committed.

1. Read `TEMPLATE_SOURCE` to determine the upstream template repo
2. Read `TEMPLATE_VERSION` to determine what was last synced
3. Check the latest release tag on the template repo:
   `gh release list --repo <template> --limit 1`
4. If already up to date — inform the human and exit cleanly
5. Clone the template to a temporary location:
   `git clone git@github.com:<template>.git /tmp/agentic-sync`
6. Copy `base/` from the template into the local repo:
   `cp -r /tmp/agentic-sync/base/ ./base/`
7. Show the human a diff of all changes:
   `git diff base/`
8. Ask for confirmation before proceeding:
   > *"These changes will be committed to base/. Proceed? [y/N]"*
   - If no — restore `base/` to its previous state and exit cleanly
9. Update `TEMPLATE_VERSION` with the new version
10. Stage and commit:
    `chore: sync base/ from <template> <version>`
11. Clean up: `rm -rf /tmp/agentic-sync`
12. Inform the human — list what changed and remind them to raise a PR

**Never sync without human confirmation of the diff.**
**Never modify any local files** (`AGENTS.local.md`, `REPOS.md`, etc.) during a sync.

---

### Requirements Session (Phase 1)

Run interactively by a human. Captures business needs as Requirement issues
in the agentic repo. No branch, no commit, no PR — the issue is the artefact.

1. Read context (see Session Initialisation)
2. Converse with the human to distil the requirement
3. Create a GitHub Issue in the agentic repo with `requirement` + `backlog` or `draft` label
4. Confirm the issue URL to the human

### Scoping Session (Phase 2)

Run interactively by a human. Decomposes a Requirement into Feature issues
in the relevant domain repo(s). No branch, no commit, no PR.

1. Read context (see Session Initialisation)
2. Read the target Requirement issue in full
3. Converse with the human to scope the Feature(s)
4. Identify whether the Feature has UI/UX impact:
   - Not every requirement has a UI impact
   - A single requirement may produce multiple features, some with UI impact and some without
   - For any feature with UI impact: design the UX now — ASCII mockups, flow descriptions,
     field layout, error states, colour/theming decisions — and include it in the feature issue
   - Do not leave UX decisions to the Feature Design Session or implementation
5. Create Feature issue(s) in the domain repo with `feature` + `backlog` label
6. Wire sub-issue relationship: Feature → parent Requirement
7. Add Feature to org Project
8. When human confirms ready: apply `in-design` label → triggers Feature Design Session

### Feature Design Session (Phase 3)

Triggered automatically by GitHub Actions when a Feature issue is labelled `in-design`.
Runs in the domain repo context. Decomposes the Feature into Task sub-issues.

1. Read context (see Session Initialisation)
2. Read the Feature issue spec in full
3. Analyse the codebase to understand what exists and what must be built
4. Create Task sub-issues under the Feature issue (ordered by creation sequence)
5. Create the feature branch: `feature/N-description` where N is the Feature issue number
   — this auto-links the branch to the Feature issue
6. Apply `in-development` label on the Feature issue → triggers Dev Session
7. Exit cleanly — do not push files, do not open a PR

### Dev Session (Phase 4)

Triggered automatically by GitHub Actions when a Feature issue is labelled `in-development`.
Runs on the feature branch in the domain repo. Processes Task sub-issues to completion.

1. Read context (see Session Initialisation)
2. Query open Task sub-issues on the Feature issue, ordered by issue number
3. For each Task:
   - Implement the work described in the Task issue
   - Build and test — if either fails, stop immediately and exit with error
   - Commit: `feat: [task description] — task N of N (#feature-issue)`
   - Close the Task issue: `gh issue close <task-number>`
4. When all Tasks are closed — exit cleanly
5. The workflow handles: push, PR creation with `Closes #N`, applying `in-review` label

### Interactive Session

Run manually by a human, typically to investigate or recover from a workflow failure,
or for exploration and manual work outside the automated pipeline.

1. Read context (see Session Initialisation)
2. Confirm not on `main` before making any changes
3. Follow the same build/test discipline as Dev Session

### Foreground Recovery

When the GitHub Actions workflow fails (build red, tests failing, conflict), the human
will open an Interactive Session to diagnose and fix. The following rules apply:

- Query open Task sub-issues on the Feature issue before touching any code
- Diagnose the root cause from the exact error output — do not guess
- Fix only what is failing; do not expand scope or refactor surrounding code
- After fixing: build, test, commit, close the Task issue, and push
- Inform the human what was fixed
- If the automatic re-trigger does not start the workflow, apply `in-development`
  label again to re-trigger the Dev Session
- If the fix requires a contract change or broad refactor, stop and raise it before proceeding

---

## Git Rules

One branch per Feature. Tasks are commits on that branch, not separate branches.

**Rules:**
- Never commit or make changes on `main` — unconditional
- Never push from within a recipe — the workflow pushes after the recipe exits cleanly
- Never open a PR from within a recipe — the workflow handles this
- Never merge pull requests — leave that for human review
- **Always use `git mv` to rename or move tracked files** — never OS-level `mv`
- **Stage new files immediately** using `git add <file>` after creating them
- Branch names: `feature/N-description` where N is the Feature issue number
- Commit messages per task: `feat: [task description] — task N of N (#N)`
- PR title: `feat: [Feature issue title]`
- PR body: `Closes #N` where N is the Feature issue number

---

## Testing — Universal Rules

- Every piece of logic must have tests
- Tests must be executed and must pass — writing tests without running them
  does not satisfy this rule
- Tests must cover: success cases, failure cases, and edge cases
- Never claim a task complete with failing tests
- Fix failing tests before moving to the next step
- Unit tests must not require external services — isolate infrastructure dependencies
- See the relevant file in `base/standards/` for language-specific test commands,
  frameworks, naming conventions, and patterns

---

## Build Verification — Universal Rules

- The build must pass cleanly before claiming a task complete
- Report exact command output on any failure — diagnose before retrying
- See the relevant file in `base/standards/` for language-specific build commands

---

## Working Principles

- Analyse the full problem before modifying any code
- Prefer small, incremental changes over large rewrites
- When requirements are ambiguous, ask — never invent behaviour
- Correctness and maintainability take precedence over cleverness
- Do not make changes outside the scope of the current task
- Propose large refactors before implementing them — never execute without approval

---

## Base Directory — Read Only

The `base/` directory is managed exclusively by the `agentic-development` template.
**Never modify any file under `base/` directly** — not even minor edits.

If a change to the global protocol or standards is needed:
1. Clone `eddiecarpenter/agentic-development` locally
2. Make and test the changes there
3. Push and raise a PR for human review
4. Once merged and tagged, sync `base/` into this repo using the sync process

For project-specific overrides that cannot wait for a template sync, add them to
`AGENTS.local.md` instead — that is what it is for.

---

## Sensitive Operations — Ask Before Proceeding

Always ask a human before:
- Deleting any file
- Broad refactors across multiple packages
- Changing public APIs
- Modifying core business logic (charging, payments, financial calculations)
- Introducing new dependencies
- **Modifying any contract** — see Contract Rules below

---

## Recipe Rules

Goose recipes live in two places:

| Path | Editable | Purpose |
|---|---|---|
| `.goose/recipes/*.yaml` | ❌ Never (managed by template) | The complete recipe — instructions, parameters, model settings |
| `base/recipes/*.md` | ❌ Never | Human-readable reference docs for each session type |

**`.goose/recipes/*.yaml` files are managed by the `agentic-development` template.**
**`base/recipes/*.md` files are read-only reference documentation.**
Neither should ever be modified locally.

The six standard recipes are:

| File | Stage | Trigger |
|---|---|---|
| `requirements-session.yaml` | Stage 1 | Human (interactive) |
| `feature-scoping.yaml` | Stage 2 | Human (interactive) |
| `feature-design.yaml` | Stage 3 | Automatic — `in-design` label |
| `dev-session.yaml` | Stage 4 | Automatic — `in-development` label |
| `pr-review-session.yaml` | Stage 4b | Automatic — PR review submitted |
| `issue-session.yaml` | Stage 4c | Automatic — issue assigned to agent |
| `foreground-recovery.yaml` | Recovery | Human (interactive) — workflow failure |

- Customisation of agent behaviour belongs in `AGENTS.local.md`
- If a recipe needs to change, raise it against `eddiecarpenter/agentic-development`
  and let it flow in via `gh agentic sync`
- `gh agentic verify` detects and flags any local modifications to recipe files

---

## Contract Rules

A **contract** is any structure or schema shared with an external system or process.
Contracts must **never be modified without explicit human approval**, regardless of
how minor the change appears.

The meta-rule: **You can never know all consumers of a contract.** A field that
appears unused may be read by a Java service, a database migration, a reporting
tool, or a downstream event processor. Adding, removing, or renaming fields
without approval is always a breaking change risk.

### What counts as a contract

**Kafka event schemas** — any struct that is serialised and published to a Kafka
topic, or deserialised from a Kafka topic. These are consumed by other services
that you cannot see. The schema is defined by the upstream publisher — the
consuming service must accept what it receives, not invent fields.

**Database-serialised structs** — any struct that is marshalled into a database
column (e.g. as JSON or JSONB). Other applications may read those columns directly.

**GraphQL schema** — any type, field, query, mutation, or subscription exposed via
the GraphQL API. External clients depend on these names and shapes.

**Store query interfaces** — sqlc-generated query interfaces. Modify the SQL, not the Go.

### Rules

1. **Never add, remove, or rename fields** on a contract struct without explicit
   human approval.

2. **Never invent fields** that the upstream publisher does not send.

3. **Internal IDs belong in internal structs**, not in contracts.

4. **When in doubt, ask.** Stop and raise it with the human before making any change.

5. **Document the reason** for any approved contract change in `DECISIONS.md`
   with an ADR, including which consumers were checked and what the migration plan is.

---

## Communication

- Explain what changed, referencing specific files, packages, and issue numbers
- Explain reasoning behind design decisions
- Explicitly highlight risks for changes touching critical business logic
- State clearly when a verification step could not be performed
- Prefer clarity over brevity when describing risks

---

## Task Lifecycle

**After each task completes (before moving to the next):**
1. Append significant decisions to `DECISIONS.md` in ADR format (if applicable)
2. Close the Task issue: `gh issue close <task-number> --repo <domain-repo>`
3. Commit: `feat: [task description] — task N of N (#feature-issue)`

**When all tasks are complete:**
1. Exit cleanly — do not push, do not open a PR
2. The workflow pushes and opens the PR automatically

**ADR format for DECISIONS.md:**
```
## ADR-NNN — Title
**Status:** Accepted
**Area:** Which part of the system
**Decision:** What was decided
**Rationale:** Why
**Consequences:** What this means going forward
```
