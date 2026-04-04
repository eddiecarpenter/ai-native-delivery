# Notify User

## Purpose

Send a notification to the system owner that human action is required.
Adapts automatically to the execution context — headless or interactive.

## When to Use

Call this skill whenever the pipeline reaches a point where the human must act:
- PR is ready for review
- PR has been updated and needs re-review
- Feature has been sent to design (automation taking over)
- Fix has been pushed and the workflow needs confirming

## Context Detection

Check the `GITHUB_ACTIONS` environment variable:
- `"true"` → running headlessly in a GitHub Actions workflow
- absent or any other value → running interactively (Claude Code, Goose, terminal)

## How to Notify

### Headless (GitHub Actions)

Post a comment on the current issue or PR. This triggers GitHub's notification
system — email, GitHub Mobile push, and the gh-notify LaunchAgent (if installed).

```bash
# For a PR:
gh pr comment $PR_NUMBER --body "⚡ **Action required:** $MESSAGE"

# For an issue:
gh issue comment $ISSUE_NUMBER --body "⚡ **Action required:** $MESSAGE"
```

Replace `$MESSAGE` with a specific, actionable description — include the PR or
issue number so the human knows exactly where to go.

### Foreground (Interactive)

Use the local OS notification system with sound:

```bash
if command -v osascript &>/dev/null; then
  # macOS
  osascript -e "display notification \"$MESSAGE\" with title \"Agentic Pipeline\" sound name \"Glass\""
elif command -v notify-send &>/dev/null; then
  # Linux
  notify-send "Agentic Pipeline" "$MESSAGE"
else
  # Fallback
  echo "⚡ ACTION REQUIRED: $MESSAGE"
fi
```

## Instructions for the Agent

1. Determine the message — be specific (include PR/issue number where relevant)
2. Detect context: `echo $GITHUB_ACTIONS`
3. Execute the appropriate method above
4. Do not skip this step — it is how the system owner knows to act
