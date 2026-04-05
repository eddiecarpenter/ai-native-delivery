# Update Project Template

## Purpose

Extract the live GitHub Project configuration and save it as the canonical
template in `base/project-template.json`. This ensures that board customisations
(status column names, colours, descriptions) flow to all downstream environments
via `gh agentic sync`.

## When to Use

Invoke this skill when the human says any of the following:
- "Save the current project config as the template"
- "Update the project template from the live project"
- "Extract project settings"

## What the Agent Does

Execute these steps in order — do not skip any step.

1. **Identify the project** — resolve the project ID from the repository variable
   `vars.AGENTIC_PROJECT_ID`, or query the repo's linked projects via GraphQL:

   ```bash
   gh api graphql -f query='
   {
     repository(owner: "<owner>", name: "<repo>") {
       projectsV2(first: 5) {
         nodes {
           id
           title
           number
         }
       }
     }
   }'
   ```

   If multiple projects are linked, ask the human which one to use.

2. **Query the status field options** — use GraphQL to extract the status field
   (a `ProjectV2SingleSelectField`) and its options:

   ```bash
   gh api graphql -f query='
   {
     node(id: "<project-id>") {
       ... on ProjectV2 {
         fields(first: 20) {
           nodes {
             ... on ProjectV2SingleSelectField {
               name
               options {
                 name
                 color
                 description
               }
             }
           }
         }
       }
     }
   }'
   ```

   Filter the response for the field named `Status`.

3. **Write `base/project-template.json`** — format the extracted options using
   the following JSON schema:

   ```json
   {
     "statusField": {
       "options": [
         { "name": "Backlog", "color": "GRAY", "description": "" },
         { "name": "Scoping", "color": "PURPLE", "description": "" },
         { "name": "Scheduled", "color": "BLUE", "description": "" },
         { "name": "In Design", "color": "PINK", "description": "" },
         { "name": "In Development", "color": "YELLOW", "description": "" },
         { "name": "In Review", "color": "ORANGE", "description": "" },
         { "name": "Done", "color": "GREEN", "description": "" }
       ]
     }
   }
   ```

   Each option object has three fields:
   - `name` — the display name of the status column
   - `color` — the GitHub project colour constant (e.g. `GRAY`, `BLUE`, `GREEN`)
   - `description` — optional description text (empty string if none)

4. **Validate the JSON** — confirm the file is well-formed JSON before committing.

5. **Commit** — stage and commit the file:

   ```
   chore: update base/project-template.json from live project
   ```

6. **Remind the human** — after committing, remind them to raise a PR so the
   change is reviewed and merged before the next template sync.

## Label Priority Order

When resyncing item statuses from the template back to a live project, apply
this priority order to determine the correct status for each item:

1. **`CLOSED`** — if the issue or PR is closed, its status is `Done` regardless
   of labels
2. **Pipeline labels** — check for `in-review`, `in-development`, `in-design`,
   `scheduled`, `scoping` (in that order, highest priority first)
3. **`backlog`** — if no pipeline label is present and the item is open, default
   to `Backlog`

## Rules

- **Template repo only** — this operation belongs in the `agentic-development`
  template repo. Never modify `base/` in downstream repos. Downstream repos
  receive `base/project-template.json` via `gh agentic sync`.
- Do not modify the live project during this skill — it is read-only extraction.
- If the GraphQL query returns no status field, stop and report the error to
  the human.
- Always validate the JSON before committing.
