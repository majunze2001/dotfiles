#!/bin/bash
# PreToolUse hook for AskUserQuestion. On by default.
#
# A session started with CLAUDE_WORKER_NO_USER_QUESTION=1 is a worker: its
# question is always rejected, and it asks its controller instead. This wins
# over everything below.
#
# A question goes through only if one of these holds:
#   1. The session was started with CLAUDE_DISABLE_QUESTION_HOOK=1.
#   2. ~/.claude/user_online exists. The `online` and `offline` aliases set it.
# Otherwise it is rejected, and the session decides for itself.
#
# Both checks run on every call, so `online` and `offline` apply to running
# sessions without a restart. The env var is fixed when the session starts.

cat >/dev/null

if [ "$CLAUDE_WORKER_NO_USER_QUESTION" = "1" ]; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"This is a worker session: do not ask the user. Ask your controller session with SendMessage and keep working on other items; with no answer in 10 minutes, take the best option within your brief and report it."}}
JSON
  exit 0
fi

if [ "$CLAUDE_DISABLE_QUESTION_HOOK" = "1" ] || [ -e "$HOME/.claude/user_online" ]; then
  exit 0
fi

cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Use your best judgement and record the decision in the markdown tracking file"}}
JSON
exit 0
