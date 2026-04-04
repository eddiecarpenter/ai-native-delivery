# ARCHITECTURE.md — Agentic Software Delivery Framework

## Overview

The agentic software delivery framework is a set of tools, conventions, and protocols
that standardise AI-assisted software development across projects. It consists
of three layers:

1. **Template repo** (`eddiecarpenter/agentic-development`) — global standards and agent protocol
2. **Extension** (`eddiecarpenter/gh-agentic`) — tooling that creates and manages environments
3. **Project repos** — the actual software being built, governed by the framework

---

## Repositories

| Repo | Type | Purpose |
|---|---|---|
| `eddiecarpenter/agentic-development` | Template | Holds `base/AGENTS.md`, language standards, workflow definitions. Never cloned directly — consumed via `gh repo create --template`. |
| `eddiecarpenter/gh-agentic` | Tool | GitHub CLI extension. Bootstraps environments, registers repos, syncs base/. |

---

## Project topologies

### Embedded

A single repo that is both the agentic control plane and the project codebase.
Used for standalone tools, libraries, and small projects.

```
my-project/
├── CLAUDE.md
├── AGENTS.local.md
├── REPOS.md             ← empty or unused
├── base/                ← synced from template
├── cmd/
└── internal/
```

### Organisation

A dedicated agentic control plane repo (`<name>-agentic`) that governs a
collection of domain and tool repos. Each domain/tool repo is independent.

```
my-org-agentic/          ← control plane
├── CLAUDE.md
├── AGENTS.local.md
├── REPOS.md             ← registry of all domain/tool repos
├── base/
└── docs/

domains/
├── charging-domain/
└── billing-domain/

tools/
└── ocs-testbench/
```

---

## The phase model

| Phase | Name | Who runs it | What happens |
|---|---|---|---|
| 0a | Bootstrap | `gh agentic bootstrap` | Creates repo, scaffolds project, configures GitHub |
| 0b | Inception | `gh agentic inception` | Registers a new domain or tool repo |
| — | Template Sync | `gh agentic sync` | Updates `base/` from upstream template |
| 1 | Requirements | AI agent | Captures business needs as GitHub Issues |
| 2 | Scoping | AI agent + human | Decomposes requirements into features |
| 3 | Feature Design | AI agent | Decomposes features into tasks, creates branch |
| 4 | Development | AI agent | Implements tasks, commits, closes issues |

Phases 0a and 0b are deterministic — no AI involved.
Phases 1-4 are AI-driven — the agent reads context from `CLAUDE.md` and `AGENTS.md`.

---

## Two-layer agent rules

Agent behaviour is defined in two layers:

| File | Scope | Modified by |
|---|---|---|
| `base/AGENTS.md` | Global — all projects | Template sync only (`gh agentic sync`) |
| `AGENTS.local.md` | Local — this project only | Human, never overwritten by sync |

`CLAUDE.md` loads both via `@base/AGENTS.md` and `@AGENTS.local.md`.

`base/` is read-only for AI agents — changes must go through the template repo
(`eddiecarpenter/agentic-development`) and flow in via `gh agentic sync`.

---

## Template sync

Each project records its template source and last synced version:

```
TEMPLATE_SOURCE   → eddiecarpenter/agentic-development
TEMPLATE_VERSION  → v0.1.0
```

`gh agentic sync` fetches the latest release, copies `base/` into the project,
shows a diff, and asks for confirmation before committing.

---

## GitHub conventions

- One GitHub Project per project repo (linked to the repo)
- Standard label set: `requirement`, `feature`, `task`, `backlog`, `draft`,
  `in-design`, `in-development`, `in-review`, `done`
- Feature branches: `feature/N-description`
- Commit messages: `feat: [description] — task N of N (#issue)`

---

## Adding a repo

Adding a repo to the ecosystem is an architectural decision. Steps:

1. Run `gh agentic inception` (organisation topology) or create manually
2. Register in `REPOS.md` with type, stack, status, and description
3. Update this document to reflect the new repo and its role
