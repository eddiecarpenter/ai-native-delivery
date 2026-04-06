# Getting Started — AI-Native Software Delivery

> A step-by-step walkthrough that takes you from zero to a working agentic
> development environment. By the end you will have built, extended, and
> bug-fixed a URL Shortener service — experiencing every phase of the delivery
> pipeline along the way.

---

## What you will learn

This guide is organised into **three stages**, each building on the last:

| Stage | What you do | What you experience |
|---|---|---|
| [**Stage 1 — Greenfield**](#stage-1--build-the-base-greenfield) | Build a URL Shortener from scratch | Every pipeline phase: requirements → scoping → design → development → PR review → merge |
| [**Stage 2 — Day-2 development**](#stage-2--change-request-day-2-development) | Add a feature to the existing codebase | How the agent adapts when code already exists |
| [**Stage 3 — Bug fix**](#stage-3--bug-fix-phase-4c) | File a bug and assign it to the agent | The reactive Phase 4c workflow — no scoping, no design, straight to fix |

By the end of Stage 3 you will understand the full protocol — planned delivery,
iterative enhancement, and reactive response — and be ready to use it on your
own projects.

> **Scope:** This guide uses the **single-repo topology** only. Federated
> (multi-repo) topology is not covered here — see the
> [README](README.md#repository-topology) for an overview of both topologies.

**Before you begin**, complete the [Setup](#setup) section below to ensure your
environment is ready.

---

## Setup

> [!NOTE]
> **Placeholder section.** The detailed setup instructions depend on #117
> (runner-agnostic workflows) landing first. The content below outlines what is
> needed — full step-by-step detail will be added once #117 is complete and the
> guide has been test-run end to end.

### Prerequisites

Before you begin, make sure the following are installed and working:

- **[git](https://git-scm.com)** — version control
- **[GitHub CLI (`gh`)](https://cli.github.com)** — authenticated (`gh auth login`)
- **[Goose](https://block.goose.sh)** — the AI agent runtime
- **A GitHub account** with permission to create repositories

For full prerequisite details — including optional tools like Claude Code — see
the [Prerequisites section in the README](README.md#prerequisites).

### Personal Access Token (PAT)

> *Placeholder — exact scopes and creation steps to be confirmed after #117.*

You will need a GitHub Personal Access Token (classic) with at least the
following scopes:

- `repo` — full repository access
- `workflow` — GitHub Actions workflow access
- `admin:org` — organisation-level access (if using an org)

Create one at **Settings → Developer settings → Personal access tokens →
Tokens (classic)**.

### Goose provider configuration

> *Placeholder — provider setup steps to be confirmed after #117.*

Goose needs an LLM backend configured. You can use any supported provider
(OpenAI, Anthropic, Google Gemini, Ollama, etc.). If you are using Claude Code
as the provider (recommended), ensure your Anthropic API key is set.

Refer to the [Goose documentation](https://block.goose.sh) for provider
configuration.

### GitHub secrets and variables

> *Placeholder — exact configuration steps to be confirmed after #117.*

Your agentic repository will need the following secrets and variables configured
for GitHub Actions to trigger agent sessions automatically:

| Type | Name | Purpose |
|---|---|---|
| Secret | `GOOSE_AGENT_PAT` | PAT used by automated workflows to authenticate as the agent |
| Variable | `AGENT_USER` | GitHub username the agent operates as |
| Variable | `AGENTIC_PROJECT_ID` | Node ID of the GitHub Project board for automatic column sync |

### Runner configuration

> *Placeholder — runner setup depends on the outcome of #117. A self-hosted
> runner or GitHub-hosted runner with the correct tooling must be available for
> automated phases to execute. See [#117](https://github.com/eddiecarpenter/ai-native-delivery/issues/117) for details.*

---

## Stage 1 — Build the base (Greenfield)

### Overview

In this stage you will build a **URL Shortener** service from scratch and
experience every phase of the delivery pipeline:

| Endpoint | Behaviour |
|---|---|
| `POST /shorten` | Accepts a long URL, returns a generated short code |
| `GET /:code` | Redirects the caller to the original URL |
| `GET /:code` (unknown) | Returns 404 Not Found |

The application is deliberately simple. The goal is not to build a production
URL shortener — it is to experience the full agentic delivery pipeline from
end to end, with a codebase small enough that you can read and understand
every line the agent produces.

**Phases you will experience:**

```
Bootstrap → Phase 1 (Requirements) → Phase 2 (Scoping) → Phase 3 (Design)
→ Phase 4 (Development) → Phase 4b (PR Review) → Merge
```

---

### Bootstrap — create your agentic environment

Environment setup is handled by the [`gh-agentic`](https://github.com/eddiecarpenter/gh-agentic)
CLI extension — not by the AI agent. This keeps setup deterministic and
repeatable.

**Install the CLI extension:**

```bash
gh extension install eddiecarpenter/gh-agentic
```

**Run bootstrap in single-repo mode:**

```bash
gh agentic bootstrap --single
```

The command runs interactively. It will ask for:

- **Project name** — use something like `url-shortener-demo`
- **Organisation or account** — where to create the repo

**What gets created:**

| What | Why |
|---|---|
| GitHub repository | Your project home — code, issues, and automation |
| Pipeline labels | `backlog`, `requirement`, `feature`, `task`, `in-design`, `in-development`, `in-review`, etc. — the pipeline uses labels to track state and trigger automation |
| Branch protection on `main` | All changes must go through a reviewed PR |
| GitHub Project board | Visual tracking: Backlog → Scoping → Scheduled → In Design → In Development → In Review → Done |
| `base/` directory | The framework's protocol, skills, and standards |
| `.goose/recipes/` | Pre-configured agent session recipes for every pipeline phase |
| `.github/workflows/` | GitHub Actions workflows that trigger automated phases |

> **Verification checkpoint:** Open the repo in your browser (`gh repo view --web`).
> You should see the pipeline labels in the Issues tab and the Project board
> linked to the repo. The `base/` directory should contain `AGENTS.md`,
> `skills/`, and `standards/`.

**Board status:** The project board is now live but empty — no issues exist yet.

---

### Phase 1 — Requirements

Phase 1 is a conversation. You describe what you need; the agent listens,
challenges vague descriptions, and structures your words into a formal
Requirement issue with Given/When/Then acceptance criteria.

**What you do:**

Launch Goose and select the **Requirements Session (Stage 1)** recipe:

```
goose session
# Select: Requirements Session (Stage 1)
```

The agent will read the project context and then ask you what you need. Here
is an example of what the conversation looks like:

> **You:** I want to build a URL shortener. Users submit a long URL and get
> back a short code. When someone visits the short URL, they get redirected
> to the original. If the code doesn't exist, they should get a 404.
>
> **Agent:** Let me make sure I understand the scope. You want three
> behaviours:
> 1. An endpoint that accepts a long URL and returns a generated short code
> 2. An endpoint that takes a short code and redirects to the original URL
> 3. A 404 response when a code is not found
>
> Is this a public service or internal? Do you need analytics, expiration,
> or custom codes?
>
> **You:** Internal for now. No analytics, no expiration, no custom codes.
> Keep it simple — I just want to see the pipeline work end to end.
>
> **Agent:** Understood — minimal MVP. I'll capture this as a requirement.

Notice what the agent is doing: it is **actively challenging** the description
to ensure the scope is clear and nothing is assumed.

**What the agent creates:**

A Requirement issue in the repo with the `requirement` and `backlog` labels:

```markdown
Title: URL Shortener service

## User Story

As an internal user, I want a URL shortening service, so that I can share
short, memorable links that redirect to long URLs.

## Acceptance Criteria

- Given a valid long URL is submitted to POST /shorten,
  when the request is processed,
  then a unique short code is returned.

- Given a valid short code,
  when GET /:code is requested,
  then the caller is redirected to the original URL.

- Given a short code that does not exist,
  when GET /:code is requested,
  then a 404 response is returned.

## Notes

MVP scope — no analytics, expiration, or custom codes.
```

**What to observe:**

- The agent transformed your informal description into a structured user story
  with Given/When/Then acceptance criteria
- The issue has the `requirement` and `backlog` labels
- The Project board now shows the issue in the **Backlog** column

> **Verification checkpoint:** Run `gh issue list --label requirement` and
> confirm the requirement issue exists with the `backlog` label. Check the
> Project board — the issue should appear in **Backlog**.

**Board transition:** Issue appears in **Backlog**.

---

### Phase 2 — Scoping

Scoping decomposes a requirement into one or more Feature issues. Each
Feature issue defines exactly what will be built, with acceptance criteria
that the agent will implement and test against.

**What you do:**

If the scope is obvious (as it is here), the agent will offer to complete
scoping inline — in the same session as requirements. Say yes. This is not
skipping a phase; the scoping artefact (a Feature issue) is still produced.

If scoping runs as a separate session, open Goose and select the **Feature
Scoping (Stage 2)** recipe.

The agent works through a structured process:

> **Agent:** The requirement is clear and self-contained. I recommend a single
> feature with three acceptance criteria — one per endpoint behaviour. Does
> that sound right?
>
> **You:** A single feature is fine.
>
> **Agent:** I'll define the feature. Is this a backend API only, or is there
> any frontend work?
>
> **You:** API only.

**What the agent creates:**

A Feature issue with the `feature` label:

```markdown
Title: URL Shortener — POST /shorten, GET /:code, 404

## User Story

As an internal user, I want a URL shortening API, so that I can create short
codes for long URLs and redirect visitors to the original URL.

## Acceptance Criteria

- [ ] Given a valid long URL is submitted to POST /shorten,
      when the request is processed,
      then a unique short code is returned in the response.

- [ ] Given a valid short code exists,
      when GET /:code is requested,
      then the caller is redirected (HTTP 301/302) to the original URL.

- [ ] Given a short code that does not exist,
      when GET /:code is requested,
      then a 404 Not Found response is returned.

## Parent

Closes #<requirement-issue-number>
```

**The trigger — `in-design` label:**

When you confirm the feature is ready, the agent applies the `in-design`
label. **This is the handoff from human to machine.** The label change
triggers a GitHub Actions workflow that starts the automated pipeline.

From this point forward, you do not need to do anything — the agent takes
over. The `in-design` label is the bridge between the interactive phases
(where you drive) and the automated phases (where GitHub Actions drives).

The agent also transitions the parent requirement from `backlog` to
`scheduled`, indicating all features have been defined and queued.

**What to observe:**

- The Feature issue has the `feature` and `in-design` labels
- The parent requirement issue now has the `scheduled` label
- The Project board shows the feature in **In Design**

> **Verification checkpoint:** Run `gh issue list --label feature` and confirm
> the feature issue exists. Check that its labels include `in-design`. Check
> the Project board — the feature should be in **In Design**, and the
> requirement should have moved to **Scheduled**.

**Board transition:** Feature moves to **In Design**. Requirement moves to
**Scheduled**.

---

### Phase 3 — Feature Design (automated)

**Trigger:** The `in-design` label triggers a GitHub Actions workflow that
launches the agent with the **Feature Design** session. You do not need to
do anything — just watch.

**What the agent does:**

1. Reads the Feature issue — extracts the user story and acceptance criteria
2. Analyses the codebase — understands what exists (for a greenfield project,
   this is just the scaffold)
3. Creates **Task sub-issues** — ordered by implementation sequence, each with:
   - A specific piece of work to perform
   - Files to create or change
   - Acceptance criteria (testable conditions)
   - A mapping back to which feature-level criterion it satisfies
4. Verifies coverage — every acceptance criterion must be covered by at least
   one task
5. Creates the **feature branch** — `feature/<N>-<description>`
6. Applies `in-development` — triggering the next phase

For the URL Shortener, the agent might create tasks like:

| Task | Description |
|---|---|
| 1 | Scaffold Go project structure |
| 2 | Implement POST /shorten endpoint with in-memory store |
| 3 | Implement GET /:code redirect endpoint |
| 4 | Add 404 handling for unknown codes |
| 5 | Add integration tests for all endpoints |

**Important:** The Design Session writes no code. It produces only the plan
(task issues) and the branch. Implementation happens in Phase 4.

**What to observe:**

- A GitHub Actions workflow run appears in the Actions tab
- Task sub-issues are created with the `task` label, linked to the feature
- A feature branch is created (visible in the branches list)
- The `in-development` label is applied to the feature issue

> **Verification checkpoint:** Run `gh issue list --label task` and confirm
> the task sub-issues exist. Run `git fetch && git branch -r` and confirm the
> feature branch exists. Check the Actions tab — the design workflow should
> show as completed (green). The Project board should show the feature in
> **In Development**.

**Board transition:** Feature moves to **In Development**.

---

### Phase 4 — Development (automated)

**Trigger:** The `in-development` label triggers a GitHub Actions workflow
that launches the agent with the **Dev Session**.

**What the agent does:**

1. Checks out the feature branch — verifies it is not on `main`
2. Reads the Feature issue — extracts acceptance criteria
3. Queries open Task sub-issues — processes them in order
4. **For each task:**
   - Reads the task issue to understand what must be built
   - Implements the code
   - Writes tests — success cases, failure cases, and edge cases
   - Runs the full build and test suite (`go mod tidy`, `go build ./...`,
     `go test ./...`)
   - If build or tests fail — diagnoses and fixes before moving on
   - Commits: `feat: [task description] — task N of N (#feature-issue)`
   - Closes the task issue
5. Verifies acceptance criteria coverage — every criterion must have at least
   one passing test
6. Exits cleanly — the workflow pushes and opens a PR

**What to observe:**

- A GitHub Actions workflow run appears in the Actions tab
- Task issues close one by one as the agent completes them
- Commits appear on the feature branch — one per task
- When all tasks are done, a **pull request** is opened automatically with
  `Closes #<feature-issue-number>` in the body

> **Verification checkpoint:** Watch the Actions tab — the development workflow
> should progress through each task. Run `gh issue list --label task --state closed`
> to see closed tasks. When complete, run `gh pr list` — a PR should exist
> targeting `main`. The Project board should show the feature in **In Review**.

**Board transition:** Feature moves to **In Review**.

---

### Phase 4b — PR Review

The pull request is open and the `in-review` label is applied. This is where
you re-enter the process.

**What you do:**

Open the PR in your browser:

```bash
gh pr list
gh pr view <pr-number> --web
```

Review the URL Shortener code with these questions in mind:

- **Does the code match the acceptance criteria?** Check that `POST /shorten`
  returns a short code, `GET /:code` redirects, and unknown codes return 404
- **Are there tests for every criterion?** The agent should have written
  tests for success, failure, and edge cases
- **Is the code clean and idiomatic?** The agent follows the standards in
  `base/standards/`, but check that the code reads well
- **Does the commit history tell a story?** Each commit corresponds to one
  task, in order — you can trace each commit back to a task issue

**Leave a deliberate review comment:**

To experience the PR Review loop, find something to comment on — a naming
suggestion, a question about a design choice, or a minor improvement. Submit
your review as **Request changes** or **Comment**.

**What happens next:**

When you submit a review, a GitHub Actions workflow triggers the **PR Review
Session** automatically. The agent:

1. Fetches all unresolved review comments
2. Classifies each as a **question** or a **change request**
3. **Questions** — replies inline with an explanation
4. **Change requests** — implements the fix, updates tests, builds, tests,
   commits, and replies to the comment
5. Pushes the fixes — new commits appear on the PR

You can then re-review. This cycle continues until you are satisfied.

**What to observe:**

- A workflow run appears in the Actions tab after you submit your review
- The agent replies to your comments inline
- New commits appear addressing your feedback
- The PR is updated with the fixes

> **Verification checkpoint:** After submitting your review, watch the Actions
> tab for the PR Review workflow. Check that the agent replied to your
> comments and pushed fix commits. Re-review if needed.

---

### Merge

When you are satisfied with the code, approve and merge the PR:

```bash
gh pr merge <pr-number> --squash   # or --merge, depending on your preference
```

**What happens automatically on merge:**

- The Feature issue is **closed** (the PR body contains `Closes #N`)
- The feature branch is cleaned up
- The parent Requirement issue transitions to **Done** when all its child
  features are closed
- The Project board reflects the final state

**Board transition:** Feature moves to **Done**. Requirement moves to **Done**.

> **Verification checkpoint:** Run `gh issue view <feature-number>` and
> confirm it is closed. Check the Project board — both the feature and the
> requirement should be in **Done**. Run `git pull` on `main` — the URL
> Shortener code should be there.

### What you have accomplished

You have just delivered a feature through the full AI-native delivery
pipeline:

- A **Requirement issue** with a formal user story and acceptance criteria
- A **Feature issue** with scoped acceptance criteria linked to the requirement
- **Task sub-issues** that decomposed the feature into ordered, implementable
  work
- A **feature branch** with one commit per task
- **Tests** covering every acceptance criterion
- A **pull request** reviewed by you and fixed by the agent
- A **merged result** on `main` with full traceability from requirement to code

Every artefact traces back to the one before it. This is the governance that
makes agentic development trustworthy.

---

## Stage 2 — Change request (Day-2 development)

### Overview

In Stage 1 you built a URL Shortener from scratch — a greenfield project where
every file was new. In Stage 2 you will add a feature to that **existing**
codebase. This is day-2 development: the agent must understand what already
exists before it can design and implement something new.

The key difference is not what you do — the phases are the same. The difference
is **how the agent thinks**. During scoping it reads existing code. During
design it creates tasks that extend existing files rather than creating new ones.
During development it works within an established architecture rather than
inventing one.

This stage uses the same URL Shortener repo you built in Stage 1.

---

### Phase 1 — New requirement

Open a Requirements Session just as you did in Stage 1:

```
goose session
# Select: Requirements Session (Stage 1)
```

This time, describe a change to the existing URL Shortener. For example:

> **You:** I want to add a hit counter to the URL shortener. Every time
> someone visits a short URL, the visit count should be incremented. I want
> an endpoint to retrieve the visit count for a given short code.
>
> **Agent:** So you want two new behaviours on top of the existing shortener:
> 1. Track visit count — increment a counter each time GET /:code redirects
> 2. A new endpoint to retrieve the count — something like GET /:code/stats
>
> Should the counter be persistent, or is in-memory acceptable? Any
> authentication on the stats endpoint?
>
> **You:** In-memory is fine. No authentication — keep it simple.

The agent creates a new Requirement issue, just as before. The process is
identical.

> **Verification checkpoint:** Run `gh issue list --label requirement` and
> confirm the new requirement issue exists with the `backlog` label.

---

### Phase 2 — Scoping (agent reads existing code)

This is where day-2 development diverges from greenfield. When the agent
scopes this feature, it **reads the existing codebase first**.

In Stage 1, the agent had nothing to work with — it designed everything from
scratch. Now it has a working URL Shortener with handlers, a store, tests,
and a project structure. The agent analyses all of this before proposing a
feature scope.

**What to observe during scoping:**

- The agent examines the existing code to understand the current architecture
- It identifies which files and packages need to change vs what is new
- The acceptance criteria it writes account for the existing implementation
  (e.g. "the existing redirect handler increments a counter" rather than
  "create a redirect handler")
- The feature scope is smaller because infrastructure already exists

The agent creates a Feature issue and applies `in-design`, just as in Stage 1.

> **Verification checkpoint:** Read the Feature issue. Notice how the
> acceptance criteria reference existing behaviour — "when the existing
> redirect endpoint is called" rather than "create a redirect endpoint".
> The Project board should show the new feature in **In Design**.

---

### Phases 3 & 4 — Automated design and development

The automated phases run exactly as they did in Stage 1 — the `in-design`
label triggers design, and `in-development` triggers development. But the
**content** of the tasks will be noticeably different.

**What to observe during design (Phase 3):**

- The agent reads the existing codebase before creating tasks
- Tasks are shaped around what already exists: "add a counter field to the
  existing store struct" rather than "create a store"
- Fewer tasks overall — the scaffold, project structure, and base endpoints
  already exist
- Tasks reference existing files by name

**What to observe during development (Phase 4):**

- The agent modifies existing files rather than creating everything new
- Tests extend the existing test suite rather than building from scratch
- The agent reuses existing patterns (error handling, HTTP response formats,
  store interface) rather than inventing new ones
- Build and test commands are the same (`go build ./...`, `go test ./...`)

Monitor progress the same way:

```bash
gh run list --limit 5
gh issue list --label task --state open
gh issue list --label task --state closed
```

> **Verification checkpoint:** When the PR is opened, review the diff. Notice
> that the changes are **additive** — modifying and extending existing files,
> not rewriting them. The commit history should show incremental changes
> within the established architecture.

---

### Merge

Review and merge the PR, just as in Stage 1:

```bash
gh pr list
gh pr view <pr-number> --web
# Review, then:
gh pr merge <pr-number> --squash
```

> **Verification checkpoint:** After merging, pull `main` and confirm the
> hit counter feature works alongside the original shortener. The Project
> board should show both features in **Done**.

---

### What to notice — how day-2 differs from greenfield

Take a moment to compare the two stages:

| Aspect | Stage 1 (Greenfield) | Stage 2 (Day-2) |
|---|---|---|
| **Scoping** | Agent designs from scratch | Agent reads existing code first |
| **Task count** | More tasks — everything is new | Fewer tasks — infrastructure exists |
| **Task shape** | "Create X" | "Extend X", "Add Y to existing Z" |
| **Files touched** | All new | Mix of modified and new |
| **Tests** | New test suite | Extended test suite |
| **Architecture** | Agent invents patterns | Agent follows existing patterns |

The protocol is the same — phases, labels, automation. But the agent's
**reasoning** adapts to what already exists. This is what makes the framework
useful beyond the first feature: the agent is not a one-shot code generator,
it is a participant that understands context.

---

## Stage 3 — Bug fix (Phase 4c)

### Overview

Stages 1 and 2 followed the **planned delivery** pipeline: requirement →
scoping → design → development → review → merge. Every phase ran in order,
producing artefacts that fed the next phase.

Stage 3 is different. Bug fixes are **reactive** — there is no requirements
conversation, no scoping session, no design phase. You file an issue, assign
it to the agent, and Phase 4c handles it directly: acknowledge, locate, fix,
PR.

This is the fastest path through the pipeline and the one you will use most
often for day-to-day maintenance.

---

### File the bug issue

Create a bug issue in your URL Shortener repo. The agent routes by the `bug`
label — the label is what triggers the correct behaviour.

> [!NOTE]
> **Placeholder.** The exact bug issue text below will be replaced with a
> pre-scripted bug based on a real gap discovered during the end-to-end test
> run of this guide. For now, use the example below or substitute your own
> bug found while testing the URL Shortener.

**Example bug issue:**

```bash
gh issue create \
  --title "GET /:code returns 200 instead of 301/302 redirect" \
  --body "$(cat <<'ISSUE_EOF'
## Bug

When a valid short code is looked up via `GET /:code`, the server returns
an HTTP 200 with the target URL in the response body instead of performing
an HTTP 301 or 302 redirect.

## Expected behaviour

`GET /:code` should return an HTTP 301 (or 302) redirect with the `Location`
header set to the original URL.

## Actual behaviour

`GET /:code` returns HTTP 200 with a JSON body containing the URL. The
caller is not redirected.

## Steps to reproduce

1. POST /shorten with a valid URL — get back a short code
2. GET /:code with the returned code
3. Observe the response status code — it is 200, not 301/302
ISSUE_EOF
)" \
  --label bug
```

> **Verification checkpoint:** Run `gh issue list --label bug` and confirm
> the bug issue exists.

---

### Assign to the agent user

The Phase 4c trigger is **issue assignment**. When an issue with the `bug`
label is assigned to the agent user, a GitHub Actions workflow launches the
**Issue Session** automatically.

```bash
gh issue edit <bug-number> --add-assignee <agent-username>
```

Replace `<agent-username>` with the GitHub username configured as the agent
user (the `AGENT_USER` variable you set during setup).

---

### Watch Phase 4c

Once assigned, the workflow triggers and the agent takes over. Here is what
happens:

1. **Acknowledges** — the agent posts a comment on the issue confirming it
   has picked up the bug
2. **Routes by label** — sees the `bug` label and enters the bug-fix flow
   (not the question flow)
3. **Reads the issue** — extracts the bug description, expected behaviour,
   actual behaviour, and reproduction steps
4. **Locates the bug** — searches the codebase for the relevant code,
   identifies the root cause
5. **Scope check** — verifies the fix is contained to files directly related
   to the bug. If the fix would require broader changes, the agent posts a
   comment and adds a `needs-human` label instead of proceeding
6. **Creates a fix branch** — `fix/<N>-<description>` where N is the bug
   issue number
7. **Implements the fix** — minimal change to resolve the bug
8. **Writes or updates tests** — ensures the bug is covered by a regression
   test
9. **Builds and tests** — runs the full suite to confirm nothing is broken
10. **Exits cleanly** — the workflow pushes the branch and opens a PR

**What to observe:**

- A workflow run appears in the Actions tab shortly after assignment
- The agent posts an acknowledgement comment on the bug issue
- A fix branch appears (check `git fetch && git branch -r`)
- A PR is opened with the minimal fix and a regression test

```bash
# Monitor the workflow
gh run list --limit 5

# Check for the agent's comment on the bug issue
gh issue view <bug-number>

# Check for the PR
gh pr list
```

> **Verification checkpoint:** After the workflow completes, confirm:
> 1. The agent commented on the bug issue
> 2. A PR exists with a fix branch
> 3. The PR contains a minimal change (not a refactor)
> 4. A regression test exists for the specific bug

---

### Merge

Review and merge the bug-fix PR just as you would any other:

```bash
gh pr view <pr-number> --web
# Review the fix, then:
gh pr merge <pr-number> --squash
```

When the PR merges, the bug issue is closed automatically.

> **Verification checkpoint:** Confirm the bug issue is closed and the fix
> is on `main`. Run the tests locally (`go test ./...`) to verify the
> regression test passes.

---

### What to notice — reactive vs planned

Compare Stage 3 with Stages 1 and 2:

| Aspect | Stages 1 & 2 (Planned) | Stage 3 (Reactive) |
|---|---|---|
| **Entry point** | Requirements conversation | Bug issue filed |
| **Phases** | Requirements → Scoping → Design → Development → Review | Assignment → Fix → Review |
| **Scoping** | Agent and human define scope together | No scoping — scope is the bug |
| **Design** | Agent creates task sub-issues | No design — single fix |
| **Trigger** | `in-design` label | Issue assigned to agent |
| **Branch** | `feature/<N>-...` | `fix/<N>-...` |
| **Agent routing** | By pipeline label (`in-design`, `in-development`) | By issue label (`bug`) |

The planned pipeline exists for features — work that needs to be designed
before it is built. Bug fixes skip the design overhead because the "design"
is implicit: find the bug, fix it, prove the fix works.

This is not cutting corners. The agent still builds, tests, and opens a
reviewed PR. The governance is the same — only the path through the pipeline
is shorter.

---
