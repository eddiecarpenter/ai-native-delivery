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
