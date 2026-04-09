# Refresh Claude Code CI Credentials

## Purpose

Refresh the `CLAUDE_CREDENTIALS_JSON` GitHub secret used by the agentic CI workflows.
Run this whenever a CI job fails with "Claude Code authentication failed" or whenever
you suspect the stored credentials are stale or revoked.

## When to Invoke

- A CI job fails at the "Validate Claude Code credentials" step
- You have just logged back in to Claude Code after a session was revoked
- Routine maintenance before a known long gap in CI activity

## What the Agent Does

1. Check that `~/.claude/.credentials.json` exists and is non-empty. If missing, stop
   and tell the user to log in first: `claude login`

2. Capture a checksum of the current credentials file:
   ```
   CREDS_BEFORE=$(sha256sum ~/.claude/.credentials.json | cut -d' ' -f1)
   ```

3. Run a live auth test to trigger a token refresh:
   ```
   claude -p "hi"
   ```
   If this fails, stop — the session is revoked. Tell the user to run `claude login`
   and then invoke this skill again.

4. Compare the checksum:
   ```
   CREDS_AFTER=$(sha256sum ~/.claude/.credentials.json | cut -d' ' -f1)
   ```

5. Update the GitHub secret regardless of whether the checksum changed
   (the user is running this explicitly to restore CI, so always write it):
   ```
   gh secret set CLAUDE_CREDENTIALS_JSON \
     --repo <repo> \
     --body "$(cat ~/.claude/.credentials.json | base64 | tr -d '\n')"
   ```
   Where `<repo>` is derived from `git remote get-url origin` — parse the
   `owner/name` from the URL.

   If the checksum changed, note: "Credentials were rotated — secret updated with
   fresh token."
   If unchanged, note: "Credentials unchanged — secret updated as requested."

6. Confirm to the user:
   - The repo the secret was updated in
   - Whether the credentials were rotated or unchanged
   - Next step: re-run the failed CI job

## Rules

- This skill runs interactively only — never in CI
- Do not commit any files
- Do not push anything
