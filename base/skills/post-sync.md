# Post-Sync Upgrade

## Purpose

Handle post-sync upgrade actions that a template sync has left behind in
`POST_SYNC.md`. This skill ensures consuming repos are fully upgraded before
any pipeline work continues.

## When to Invoke

Invoked by `session-init` when `POST_SYNC.md` exists in the repository root.
Do not invoke this skill directly — session-init handles detection and delegation.

## What the Agent Does

Behaviour depends on the session type.

### Interactive sessions

1. Print: `Post-sync upgrade process has started`
2. Read `POST_SYNC.md` in full
3. Use judgement to identify and execute any required actions described in the file —
   these may include running commands, modifying configuration, renaming files,
   updating settings, or any other migration step the template upgrade requires
4. Delete `POST_SYNC.md` from the repository root
5. Print: `Post-sync upgrade complete. Normal operations can now be resumed.`
6. Return control to session-init to continue the session

### Automated sessions (feature-design, dev-session, pr-review-session, issue-session)

1. Print a warning that `POST_SYNC.md` is present and contains pending post-sync
   actions that must be resolved before automated pipeline work can proceed
2. List the contents or a summary of the file so the operator can see what is pending
3. Exit immediately — do not perform any pipeline work

## Rules

- This is a skill (agent instruction document), not executable code — it defines
  what the agent should do, not a script to run
- The agent must read and understand the full contents of `POST_SYNC.md` before
  taking any action
- In interactive sessions, every action described in `POST_SYNC.md` must be completed
  before the file is deleted — do not delete the file if any action failed
- In automated sessions, no pipeline work may proceed — the session must exit cleanly
  after printing the warning
- If an action in `POST_SYNC.md` is ambiguous or risky, ask the human before proceeding
- Never modify `POST_SYNC.md` — either delete it after all actions are complete
  (interactive) or leave it in place (automated)
