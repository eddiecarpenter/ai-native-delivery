# Notify User

## Purpose

Send an OS notification to the system owner that human action is required or
a session has completed. Foreground (OS) notifications only — no headless path.

## When to Use

Call this skill whenever the pipeline reaches a point where the human must act:
- PR is ready for review
- PR has been updated and needs re-review
- Feature has been sent to design (automation taking over)
- Fix has been pushed and the workflow needs confirming

## Notification Rules

- **Always notify** when human input is needed (blocking — the session cannot continue)
- **Notify on completion** only when the session has been running longer than the
  configurable threshold (default: 5 minutes / 300 seconds)
- **Never notify** on completion if the session completed in under the threshold
  and no human input was required

## Session Timing

Track session start time at the beginning of any session that uses notifications:

```bash
SESSION_START=$(date +%s)
```

Before sending a completion notification, check elapsed time:

```bash
SESSION_ELAPSED=$(( $(date +%s) - SESSION_START ))
SESSION_THRESHOLD=${NOTIFY_THRESHOLD_SECONDS:-300}  # default 5 minutes
if [ "$SESSION_ELAPSED" -gt "$SESSION_THRESHOLD" ]; then
  # send completion notification
fi
```

The `NOTIFY_THRESHOLD_SECONDS` environment variable can be set to override the
5-minute default. Set it in the shell environment before launching the session.

## How to Notify

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
2. Check whether this is a **blocking** notification (input needed) or a **completion** notification:
   - **Blocking**: send the notification immediately — always
   - **Completion**: check `SESSION_ELAPSED` against `SESSION_THRESHOLD` — only notify if threshold exceeded
3. Execute the OS notification command above
4. Do not skip this step — it is how the system owner knows to act
