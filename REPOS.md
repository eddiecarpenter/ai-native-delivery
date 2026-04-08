# REPOS.md — Repository Registry

This file is the authoritative list of all repositories that make up the solution.
Each entry is an independently deployable monorepo with its own codebase and GitHub
Issues. Coding standards are global and defined in `base/standards/`.

Repos are cloned into a local directory named after the plural of their type — e.g.
`type: domain` clones into `domains/<name>`, `type: tool` clones into `tools/<name>`.
These directories are gitignored — each developer clones repos locally on first use.
At session start, agents check that all active repos are present and prompt the user
to clone any that are missing. Clone command: `git clone <repo> <type>s/<name>`

Changing a repo's type moves it to a different directory — update the type field and
reclone (or `mv`) locally.

Only humans add or remove entries. Adding a repo is an architectural decision and
must be reflected in `docs/ARCHITECTURE.md`.

---

<!-- Add repo entries below this line -->

<!-- This repo uses Embedded topology — it is self-contained and does not govern other repos.
     gh-agentic is a related tool but has its own independent agentic process. -->
