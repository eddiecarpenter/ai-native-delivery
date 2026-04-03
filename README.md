# agentic-development

A framework for AI-assisted software development using an agentic SDLC process.

---

## Getting Started

### Prerequisites

Before running the bootstrap you will need:

- [git](https://git-scm.com)
- [GitHub CLI](https://cli.github.com) — authenticated (`gh auth login`)
- A GitHub Personal Access Token (PAT) with `repo`, `workflow`, and `admin:org` scopes
- One of the following agent CLIs:
  - [Goose](https://block.github.io/goose)
  - [Claude Code](https://claude.ai/code)

### Bootstrap a new environment

**First, navigate to the folder where you want the new agentic repo to be created:**
```bash
cd ~/Development/my-projects   # or wherever you keep your repos
```

Then download the bootstrap script, verify its integrity, and run it:

```bash
gh api repos/eddiecarpenter/agentic-development/contents/bootstrap.sh \
  --jq '.content' | base64 -d > /tmp/bootstrap.sh \
  && gh api repos/eddiecarpenter/agentic-development/contents/bootstrap.sh.md5 \
  --jq '.content' | base64 -d > /tmp/bootstrap.sh.md5 \
  && md5sum -c /tmp/bootstrap.sh.md5 \
  && bash /tmp/bootstrap.sh
```

> **Tip:** Inspect the script before running it:
> ```bash
> gh api repos/eddiecarpenter/agentic-development/contents/bootstrap.sh --jq '.content' | base64 -d | less
> ```

> **Note:** There will be a short pause after the agent launches while it fetches
> the protocol from the template — this is expected.

The script will:
1. Verify prerequisites are in place
2. Ask whether to use Goose or Claude Code
3. Launch the Phase 0a Environment Bootstrap Session
4. Guide you through creating and configuring your new agentic environment
5. Clone the new agentic repo into your current directory

Once complete, open the new agentic repo in your desktop agent and start a
Requirements Session (Phase 1).

---

## Using this as your own template (3rd parties)

1. Fork this repo to your own GitHub account or organisation
2. Update `TEMPLATE_SOURCE` to point to your fork
3. Mark your fork as a GitHub template repo (Settings → Template repository)
4. Update the bootstrap URL in your fork's `README.md` to point to your fork

> All projects bootstrapped from your fork will sync `base/` from your fork,
> not from this repo.

---

## What this provides

| Path | Purpose |
|---|---|
| `base/AGENTS.md` | Global agent protocol — session types, git rules, testing, contracts |
| `base/standards/` | Language-specific coding standards (Go, Java, etc.) |
| `.github/workflows/` | Reusable GitHub Actions workflow definitions |
| `CLAUDE.md` | Entry point — loads `base/AGENTS.md` and `AGENTS.local.md` |
| `AGENTS.local.md` | Local overrides — project-specific rules, never overwritten by sync |
| `REPOS.md` | Repository registry — all domains, tools, and other repos in the project |
| `TEMPLATE_SOURCE` | Records which template repo this environment was bootstrapped from |
| `TEMPLATE_VERSION` | Records the template version last synced |
| `bootstrap.sh` | One-command environment bootstrap script |

---

## Two-layer rules

- **`base/AGENTS.md`** — global rules, managed by this template, never edited manually
- **`AGENTS.local.md`** — local overrides, project-specific, never overwritten by sync

`CLAUDE.md` loads both. Local rules take precedence over global.

---

## Syncing updates from the template

Syncing is handled by the agent — do not do this manually.

1. Open an agent session in your agentic repo root
2. Say: *"Sync template"*
3. The agent will check for updates, show you a diff, and ask for confirmation
4. Review the changes and confirm — the agent commits and cleans up

Only `base/` and `TEMPLATE_VERSION` are ever updated by a sync.
All local files (`AGENTS.local.md`, `REPOS.md`, `CLAUDE.md`, etc.) are never touched.
