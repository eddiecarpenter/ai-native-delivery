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
