# Project Brief — ai-native-delivery

## What this is

The `ai-native-delivery` framework is a template and protocol layer for AI-assisted
software delivery. It defines the rules, skills, workflows, and tooling conventions
that AI agents follow when working on any project that uses the framework.

The framework covers the full Continuous Delivery pipeline from requirements capture
through to a versioned, tagged release. Continuous Deployment (loading to production)
is out of scope and remains the responsibility of individual projects.

## Topology

This repo is the **Organisation control plane** for the ai-native-delivery ecosystem:

| Repo | Type | Role |
|---|---|---|
| `eddiecarpenter/ai-native-delivery` | Template / control plane | Defines global agent protocol, standards, and CI workflows |
| `eddiecarpenter/gh-agentic` | Tool | GitHub CLI extension — bootstraps and manages agentic environments |

## What is built here

- `.ai/RULEBOOK.md` — the global agent rulebook, consumed by all downstream projects
- `.ai/skills/` — playbooks for each pipeline session type
- `.ai/standards/` — language-specific build, test, and coding standards
- `.ai/.github/workflows/` — the agentic pipeline workflow definitions
- `.ai/concepts/` — architectural concepts and delivery philosophy
- `.ai/docs/examples/` — annotated examples for downstream projects

## How changes flow

Changes to the framework are developed here using the same SDLC pipeline the
framework defines. Once merged and tagged, downstream projects pull the changes
via `gh agentic sync`.

## Key conventions

- `.ai/` is read-only for AI agents in downstream projects — changes must originate here
- `LOCALRULES.md` in each downstream project holds project-specific overrides (optional)
- Template version is tracked in `.ai/config.yml` and updated automatically on each release
- Releases are triggered by `git tag vX.Y.Z && git push origin vX.Y.Z`
