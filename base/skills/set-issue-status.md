# Set Issue Status — Reference Skill

## Purpose

Set the GitHub Project V2 status for an issue using the `gh` CLI GraphQL API.
Use this skill **every time** a pipeline label is applied to an issue — in the
same operation, not as a separate step.

This skill is the single source of truth for status updates. It works in all
contexts: interactive sessions (macOS, Windows, Linux) and automated CI workflows.

## Prerequisites

- `gh` CLI authenticated and in PATH
- `AGENTIC_PROJECT_ID` repo variable set to the ProjectV2 node ID (e.g. `PVT_kwHOBODmNc4BTwOo`)
- `GH_TOKEN` set to a PAT with `project` scope (in CI: `GOOSE_AGENT_PAT`)

If `AGENTIC_PROJECT_ID` is not set, **fail with a clear error message** — do not
skip silently. All repos must have this variable configured before running sessions.

## Label-to-Status Mapping

| Label | Status |
|---|---|
| `backlog` | `Backlog` |
| `scoping` | `Scoping` |
| `scheduled` | `Scheduled` |
| `in-design` | `In Design` |
| `in-development` | `In Development` |
| `in-review` | `In Review` |
| `done` | `Done` |

All other labels are not pipeline labels — skip silently.

## Pattern

Run these steps in order. All use `gh api graphql`.

### Step 1 — Resolve the issue node ID

```bash
ISSUE_NODE_ID=$(gh api repos/{owner}/{repo}/issues/{number} --jq '.node_id')
```

Or, if the node ID is already available from a prior API call, use it directly.

### Step 2 — Find or create the project item

```bash
PROJECT_ID="${AGENTIC_PROJECT_ID}"

RESULT=$(gh api graphql -f query='
  query($issueId: ID!) {
    node(id: $issueId) {
      ... on Issue {
        projectItems(first: 100) {
          nodes {
            id
            project { id }
          }
        }
      }
    }
  }
' -f issueId="${ISSUE_NODE_ID}")

ITEM_ID=$(echo "${RESULT}" | jq -r \
  --arg pid "${PROJECT_ID}" \
  '.data.node.projectItems.nodes[] | select(.project.id == $pid) | .id')

if [ -z "${ITEM_ID}" ]; then
  # Issue not yet in the project — add it
  ADD_RESULT=$(gh api graphql -f query='
    mutation($projectId: ID!, $contentId: ID!) {
      addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) {
        item { id }
      }
    }
  ' -f projectId="${PROJECT_ID}" -f contentId="${ISSUE_NODE_ID}")
  ITEM_ID=$(echo "${ADD_RESULT}" | jq -r '.data.addProjectV2ItemById.item.id')
fi
```

### Step 3 — Resolve the Status field ID and option ID

```bash
TARGET_STATUS="In Design"   # substitute the target status name from the mapping table

FIELDS=$(gh api graphql -f query='
  query($projectId: ID!) {
    node(id: $projectId) {
      ... on ProjectV2 {
        fields(first: 50) {
          nodes {
            ... on ProjectV2SingleSelectField {
              id
              name
              options { id name }
            }
          }
        }
      }
    }
  }
' -f projectId="${PROJECT_ID}")

FIELD_ID=$(echo "${FIELDS}" | jq -r \
  '.data.node.fields.nodes[] | select(.name == "Status") | .id')

OPTION_ID=$(echo "${FIELDS}" | jq -r \
  --arg status "${TARGET_STATUS}" \
  '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == $status) | .id')
```

### Step 4 — Update the status

```bash
gh api graphql -f query='
  mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
    updateProjectV2ItemFieldValue(input: {
      projectId: $projectId
      itemId: $itemId
      fieldId: $fieldId
      value: { singleSelectOptionId: $optionId }
    }) {
      projectV2Item { id }
    }
  }
' \
  -f projectId="${PROJECT_ID}" \
  -f itemId="${ITEM_ID}" \
  -f fieldId="${FIELD_ID}" \
  -f optionId="${OPTION_ID}"
```

## Rules

- Always set status in the same operation as the label — never as a separate step or session
- If `AGENTIC_PROJECT_ID` is not set, **hard-fail with a clear error message** — do not skip silently
- If the issue is not yet in the project, add it first (Step 2 handles this)
- Never hardcode field IDs or option IDs — always resolve them dynamically (they vary per project)
- Only pipeline labels have a status mapping — all other labels are ignored
