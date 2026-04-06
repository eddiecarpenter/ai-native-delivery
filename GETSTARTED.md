# Getting Started — Build a URL Shortener with AI-Native Delivery

This is a hands-on walkthrough. By the end, you will have taken a single requirement
— a URL Shortener service — from a conversation with an AI agent all the way to a
reviewed, merged pull request. Along the way, you will see every phase of the
AI-native delivery pipeline in action and understand what the agent is doing at each step.

---

## Table of Contents

- [1 — Overview](#1--overview)
- [2 — Prerequisites](#2--prerequisites)
- [3 — Bootstrap Your Environment](#3--bootstrap-your-environment)
- [4 — Phase 1: Requirements](#4--phase-1-requirements)
- [5 — Phase 2: Feature Scoping](#5--phase-2-feature-scoping)
- [6 — Phases 3 & 4: Automated Design and Development](#6--phases-3--4-automated-design-and-development)
- [7 — Phase 4b: PR Review](#7--phase-4b-pr-review)
- [8 — Merge](#8--merge)
- [9 — What's Next](#9--whats-next)

---

## 1 — Overview

### What you'll build

A URL Shortener service in Go with three behaviours:

- **POST /shorten** — accepts a long URL and returns a short code
- **GET /:code** — redirects the caller to the original URL
- **404** — returns a not-found response if the code doesn't exist

The application is deliberately simple. The goal is not to build a production URL
shortener — it is to experience the full agentic delivery pipeline from end to end,
with a codebase small enough that you can read and understand every line the agent produces.

### What you'll learn

You will work through every phase of the pipeline:

1. **Requirements Capture** — a conversation with an AI agent that structures your
   business need into a formal requirement with Given/When/Then acceptance criteria
2. **Feature Scoping** — the agent decomposes the requirement into a feature with
   clear scope and acceptance criteria
3. **Automated Design** — GitHub Actions triggers the agent to break the feature
   into ordered task sub-issues and create a feature branch
4. **Automated Development** — the agent implements each task, writes tests, runs
   the build, and opens a pull request
5. **PR Review** — you review the agent's work, leave comments, and the agent
   responds with fixes
6. **Merge** — the feature is complete

By the end, you will understand how the protocol, the agent, and GitHub Actions work
together — and you will be ready to run your own features through the pipeline.

For deeper context on any concept, the [README](README.md) covers the full framework
in detail.

---

## 2 — Prerequisites

Before you begin, make sure the following tools and accounts are in place.

### Tools

| Tool | Purpose | Install |
|---|---|---|
| [git](https://git-scm.com) | Version control | [git-scm.com](https://git-scm.com) |
| [GitHub CLI](https://cli.github.com) (`gh`) | GitHub operations from the terminal | [cli.github.com](https://cli.github.com) |
| [Goose](https://block.goose.sh) | AI agent runtime — drives every session | [block.goose.sh](https://block.goose.sh) |
| An LLM backend | The AI model Goose uses (OpenAI, Anthropic, Google Gemini, Ollama, etc.) | Configured in Goose settings |
| [Claude Code](https://claude.ai/code) *(optional, recommended)* | Anthropic's agentic coding CLI — recommended as Goose's default provider | [claude.ai/code](https://claude.ai/code) |

### Accounts

- A **GitHub account** with a Personal Access Token (PAT) that has these scopes:
  - `repo` — full access to repositories
  - `workflow` — permission to trigger GitHub Actions workflows
  - `admin:org` — required for creating project boards and configuring branch protection

  > **Tip:** Create a fine-grained PAT scoped to the organisation or account where you
  > will create the agentic repo. This avoids granting unnecessary access to unrelated repos.

### Verify your setup

Run these commands to confirm everything is installed and authenticated:

```bash
# Git
git --version
# Expected: git version 2.x.x

# GitHub CLI — must be authenticated
gh auth status
# Expected: Logged in to github.com account <your-username>

# Goose
goose --version
# Expected: goose x.x.x

# Claude Code (optional)
claude --version
# Expected: claude x.x.x
```

If any command fails, install or authenticate the tool before continuing. The agent
cannot compensate for missing prerequisites — these are the foundation everything
else builds on.

---

## 3 — Bootstrap Your Environment

With the prerequisites in place, you are ready to create your agentic environment.
This is handled by the `gh-agentic` CLI extension — not by the AI agent.

### Why bootstrap is not AI-driven

Environment setup is deterministic. It creates repos, configures labels, sets branch
protection rules, and scaffolds the project structure. These operations must succeed
reliably every time — a misconfigured label or missing branch protection rule would
cause silent failures later in the pipeline. Deterministic Go code is the right tool
for this job; an AI agent is not.

The agent's strength is reasoning, not configuration. Bootstrap handles the
configuration so the agent can focus on what it does well: understanding requirements,
designing solutions, and writing code.

### Install the CLI extension

```bash
gh extension install eddiecarpenter/gh-agentic
```

### Run bootstrap

```bash
gh agentic bootstrap
```

The command runs interactively. It will ask you for:

- **Project name** — a short name for your project (e.g. `url-shortener-demo`)
- **Topology** — choose **Single Repo** for this walkthrough (one repo contains both
  the agentic control plane and your codebase — simplest for learning)
- **Organisation or account** — where to create the repo

### What gets created

When bootstrap completes, you will have a new GitHub repository with:

| What | Why |
|---|---|
| **Pipeline labels** (`backlog`, `requirement`, `feature`, `task`, `in-design`, `in-development`, `in-review`, etc.) | The pipeline uses labels to track state and trigger automation — every phase transition is a label change |
| **Branch protection on `main`** | Prevents direct pushes — all changes must go through a reviewed PR |
| **GitHub Project board** | Visual tracking of issues through the pipeline columns (Backlog → Scoping → In Design → In Development → In Review → Done) |
| **`base/` directory** | The framework's protocol, skills, and standards — synced from the template |
| **`CLAUDE.md`** | Entry point that loads `base/AGENTS.md` and `AGENTS.local.md` — every agent session reads this first |
| **`AGENTS.local.md`** | Your project-specific rules — starts empty, you fill it in as your project evolves |
| **`REPOS.md`** | Registry of repos in the project (for federated topology — in single repo mode, this lists just the one repo) |
| **`.goose/recipes/`** | Pre-configured agent session recipes for every phase of the pipeline |
| **`.github/workflows/`** | GitHub Actions workflows that trigger automated phases (Design, Development, PR Review) |

### Verify and open the repo

```bash
cd url-shortener-demo   # or whatever you named the project
ls base/
# Expected: AGENTS.md  skills/  standards/  .github/

gh repo view --web
# Opens the repo in your browser — check that labels and the project board exist
```

You now have a fully configured agentic environment. The protocol is loaded, the
automation is wired up, and the agent is ready to work.

Next, you will open your first session and capture the URL Shortener requirement.

---

## 4 — Phase 1: Requirements

Phase 1 is a conversation. You describe what you need; the agent listens, challenges
vague descriptions, and structures your words into a formal Requirement issue with
Given/When/Then acceptance criteria. The human drives — the agent captures and records.

### Opening a Requirements Session

Launch Goose and select the **Requirements Session (Stage 1)** recipe:

```
goose session
# Select: Requirements Session (Stage 1)
```

The agent will print `=== Requirements Session (Phase 1) — Started ===` and then
read the project brief and any existing open requirements to understand the current
context. Then it asks you what you need.

### The conversation

Here is an example of what the conversation looks like for the URL Shortener:

> **You:** I want to build a URL shortener. Users submit a long URL and get back a
> short code. When someone visits the short URL, they get redirected to the original.
> If the code doesn't exist, they should get a 404.
>
> **Agent:** Let me make sure I understand the scope. You want three behaviours:
> 1. An endpoint that accepts a long URL and returns a generated short code
> 2. An endpoint that takes a short code and redirects to the original URL
> 3. A 404 response when a code is not found
>
> Is this a public service or internal? Do you need analytics, expiration, or
> custom codes?
>
> **You:** Internal for now. No analytics, no expiration, no custom codes. Keep it
> simple — I just want to see the pipeline work end to end.
>
> **Agent:** Understood — minimal MVP. I'll capture this as a requirement.

Notice what the agent is doing here: it is not just recording your words. It is
**actively challenging** the description to ensure the scope is clear and that
nothing is assumed. If you said something vague like "a URL service", it would
push back and ask for specifics.

### What the agent does behind the scenes

After the conversation, the agent:

1. **Creates a Requirement issue** in the agentic repo with the `requirement` and
   `backlog` labels
2. **Structures the requirement** with a user story and Given/When/Then acceptance
   criteria — even though you described it informally, the agent produces a formal
   specification

### The resulting Requirement issue

The issue the agent creates looks like this:

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

This issue is now the **source of truth** for the requirement. Everything downstream
— feature scoping, design, implementation — traces back to this issue.

### Scoping inline vs separate session

If the scope is obvious (as it is for our URL Shortener), the agent will ask whether
you want to complete scoping in the same session. This is not skipping a phase — the
scoping artefact (a Feature issue) must still be produced. It simply avoids the
overhead of a separate session when the answer is already clear.

For a simple walkthrough like this one, say yes — let the agent complete scoping
inline. The next section describes what happens during scoping, whether it runs
inline or as a separate session.

---

## 5 — Phase 2: Feature Scoping

Scoping decomposes a requirement into one or more Feature issues. Each Feature issue
defines exactly what will be built, with acceptance criteria that the agent will
implement and test against.

For the URL Shortener, the requirement maps to a single feature. More complex
requirements might decompose into multiple parallel or sequential features — the
agent will guide that decision.

### The scoping conversation

If scoping runs as a separate session, open Goose and select the **Feature Scoping
(Stage 2)** recipe. If it runs inline (as we recommended above), the conversation
continues seamlessly.

The agent works through a structured process:

> **Agent:** The requirement is clear and self-contained. I recommend a single feature
> with three acceptance criteria — one per endpoint behaviour. This can be built and
> tested as one unit. Does that sound right, or would you like to split it differently?
>
> **You:** A single feature is fine.
>
> **Agent:** I'll define the feature with a user story and acceptance criteria. Let me
> also confirm — is there any UX or UI impact? This is a backend API, so I'm assuming
> no frontend work.
>
> **You:** Correct, API only.

### What the agent does during scoping

Behind the scenes, the agent is working through a structured checklist:

1. **Summarises the raw idea** — confirms understanding with you
2. **Defines the problem statement** — what problem does this solve?
3. **Writes a user story** — `As a [user], I want [goal], so that [benefit]`
4. **Determines MVP scope** — the smallest version that delivers real value
5. **Checks parallel vs serial** — can all parts be built independently (multiple
   features), or must they be sequenced (one feature with ordered tasks)?
6. **Defines acceptance criteria** — outcome-based, in checkbox format
7. **Checks for UX impact** — any design needed before implementation?
8. **Reviews the parking lot** — anything out of scope that should be captured for later?

This structure ensures nothing is missed. The agent is not just creating an issue —
it is producing a complete, testable specification.

### The resulting Feature issue

The agent creates a Feature issue that looks like this:

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

### The trigger — `in-design` label

When you confirm the feature is ready, the agent applies the `in-design` label to
the Feature issue. **This is the handoff from human to machine.** The label change
triggers a GitHub Actions workflow that starts the automated pipeline.

From this point forward, you do not need to do anything — the agent takes over.
The `in-design` label is the bridge between the interactive phases (where you drive)
and the automated phases (where GitHub Actions drives). This is why the pipeline
diagram in the [README](README.md) shows Phases 1 and 2 on the left (interactive)
and Phases 3 and 4 on the right (automated).

The agent also transitions the parent requirement from `scoping` to `scheduled`,
indicating that all features have been defined and queued for design.

### What happens next

The `in-design` label triggers the Feature Design Session automatically via GitHub
Actions. You will watch this happen in the next section — but first, take a moment
to appreciate what just happened: you described a URL shortener in plain English,
and the agent produced a formally structured, testable feature specification with
full traceability back to the original requirement.

Next, the automated phases take over.
