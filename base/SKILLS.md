# Skills Inventory

| File | Stage | Trigger | Purpose |
|---|---|---|---|
| `skills/requirements-session.md` | Stage 1 | Human (interactive) | Capture business needs as Requirement issues |
| `skills/feature-scoping.md` | Stage 2 | Human (interactive) | Decompose Requirements into Feature issues |
| `skills/feature-design.md` | Stage 3 | Automatic — `in-design` label | Create Task sub-issues and feature branch |
| `skills/dev-session.md` | Stage 4 | Automatic — `in-development` label | Implement Tasks, commit, exit for workflow to push |
| `skills/pr-review-session.md` | Stage 4b | Automatic — PR review submitted | Process inline review comments |
| `skills/issue-session.md` | Stage 4c | Automatic — issue assigned to agent | Fix bugs or answer questions |
| `skills/foreground-recovery.md` | Recovery | Human (interactive) | Diagnose and fix workflow failures |

See [`docs/skills-framework.md`](docs/skills-framework.md) for the full framework definition,
architecture, authoring rules, and governance.
