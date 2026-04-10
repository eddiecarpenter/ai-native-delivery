# Release Notes

## Purpose

Generate human-readable, well-structured release notes from git commit history
and create the GitHub release. This skill is invoked by the Release recipe when
a version tag is pushed to `main`.

---

## Steps

### Step 1 — Determine the Previous Tag

List all tags sorted by version, excluding the current tag:

```bash
git tag --sort=-version:refname | grep -v "^{{ tag }}$" | head -1
```

Store as PREV_TAG. If no previous tag exists, the release covers the full history.

### Step 2 — Collect Commits

Get all commits since the previous tag:

```bash
# If PREV_TAG exists:
git log --pretty=format:"%s (%h)" "${PREV_TAG}..HEAD"

# If no PREV_TAG:
git log --pretty=format:"%s (%h)"
```

Review the commits. Read changed files if a commit message is ambiguous.

### Step 3 — Write the Release Notes

Release notes are read by humans — developers deciding whether to sync, product
owners reviewing what changed. They are not a raw commit log. They answer:
**what changed, and why does it matter?**

**Format:**

```markdown
<One sentence summary of what this release delivers overall.>

## Features
- <What the feature does and why it matters>

## Fixes
- <What was broken and what is now correct>

## Documentation
- <What was documented or clarified>

## Chores
- <Infrastructure, dependency updates, tooling — only if notable>
```

**Rules:**
- Omit any section that has no entries
- Do not include the release tag or a title — GitHub adds the title separately
- Each bullet is one sentence, present tense: "Adds...", "Fixes...", "Removes..."
- Name the thing that changed, not the mechanism

**Commit categorisation:**

| Commit prefix | Section |
|---|---|
| `feat:` | Features |
| `fix:` | Fixes |
| `docs:` | Documentation |
| `chore:`, `ci:`, `refactor:`, `test:` | Chores (only if notable) |
| Merge commits, version bumps, automated commits | Omit |

**What to omit:**
- Merge commits (`Merge pull request #N from ...`)
- Automated commits (`chore: update .ai/config.yml`, `chore: sync ...`)
- Minor CI or tooling changes with no user impact
- Commits that duplicate another commit in the same release

**For framework releases specifically:**
Flag any changes that require downstream action — new required secrets, changed
AGENTS.md rules, renamed or new skills, breaking changes to recipe parameters.
These are the changes downstream owners most need to know about before running
`gh agentic sync`.

Write the release notes to `/tmp/release-notes.md`.

### Step 4 — Update the GitHub Release

The release already exists — it was created by the local project's publish workflow
(GoReleaser, a stub creation step, or any other means). Update its body with the
AI-generated notes:

```bash
gh release edit {{ tag }} \
  --repo {{ repo }} \
  --notes-file /tmp/release-notes.md
```

This replaces whatever notes the release was created with. If the release does not
exist for any reason, report and exit cleanly — do not attempt to create it.

### Step 5 — Report

Output the GitHub release URL and a one-line summary of what was included.
