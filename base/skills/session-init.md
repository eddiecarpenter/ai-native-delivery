# Session Init

## Purpose

Load the project environment at the start of a session, or reload it after a
mid-session template sync. Ensures the agent operates with the correct context,
repo state, rules, and skills before doing any work.

## When to Invoke

- **New session starts** — invoke this skill before anything else
- **Template synced mid-session** — the human says any of the following:
  - "template synced"
  - "I just synced the template"
  - `/template-synced`

## What the Agent Does

Execute these steps in order — do not skip any:

1. Read `docs/PROJECT_BRIEF.md` — understand what the system is and how it works

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
   If the user declines to clone missing repos, continue the session but limit all
   work to repos that are present locally. Do not reference, modify, or make
   assumptions about the content of repos that were not cloned.

3. Query open Requirement issues in the agentic repo:
   `gh issue list --repo <agentic-repo> --label requirement --state open --json number,title,labels`

4. For domain sessions — query open Feature issues in the domain repo:
   `gh issue list --label feature --state open --json number,title,labels,body`

5. Read the relevant standards file from `base/standards/` for the domain language
   (e.g. `base/standards/go.md` for Go domains)

6. Load skills — read every `.md` file in `base/skills/` (template-managed) and in
   `skills/` (local, if the directory exists). Local skills in `skills/` take
   precedence over template skills in `base/skills/` of the same name.

7. Read `TEMPLATE_VERSION` and note the current version.

## On Completion

**New session:** proceed with the work for this session.

**Template synced mid-session:** confirm to the human before resuming work:
- The new template version (from `TEMPLATE_VERSION`)
- The list of files reloaded (protocol + skills)
- Any skills added or removed compared to what was previously loaded (if detectable)

## Rules

- Do not begin any work until all steps are complete
- Do not modify any files during this skill — steps 1–7 are read-only except for
  the type folder bootstrap in step 2 (only if a folder is missing)
- If `TEMPLATE_VERSION` is missing or unreadable, warn the human and continue —
  the version file is informational, not blocking
- There is no STATUS.md — current state is derived from GitHub Issues
