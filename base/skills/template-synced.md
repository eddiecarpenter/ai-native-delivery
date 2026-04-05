# Template Synced

## Purpose

Reload all protocol files after a mid-session template sync so the agent
operates under the latest rules, standards, and skills without restarting.

## When to Use

Invoke this skill when the human says any of the following:
- "template synced"
- "I just synced the template"
- `/template-synced`

## What the Agent Does

Execute these steps in order — do not skip any step.

1. **Re-read `base/AGENTS.md`** — read the file in full; this is the global
   agent protocol and may contain updated rules, session types, or contract
   definitions.

2. **Re-read all template skills** — list `base/skills/` and read every `.md`
   file. These are the template-managed skills and may have been added, removed,
   or changed by the sync.

3. **Re-read all local skills** — if the `skills/` directory exists, list it
   and read every `.md` file. Local skills override template skills of the same
   name and are not affected by the sync, but must still be loaded to maintain
   the correct precedence.

4. **Re-read `TEMPLATE_VERSION`** — read the file and note the new version
   string.

5. **Confirm to the human** — report:
   - The new template version (from `TEMPLATE_VERSION`)
   - The list of files that were reloaded (protocol + skills)
   - Any skills that were added or removed compared to what was previously
     loaded (if detectable)

## Rules

- Do not continue normal work until all five steps are complete and
  confirmation has been given to the human.
- Do not modify any files during this skill — it is read-only.
- If `TEMPLATE_VERSION` is missing or unreadable, warn the human and continue
  with the reload — the version file is informational, not blocking.
