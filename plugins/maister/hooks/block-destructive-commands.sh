#!/bin/bash
# Block destructive commands from non-implementation subagents.
# Uses a whitelist approach: only explicitly trusted execution agents bypass the check.
# New agents are automatically protected by default.
#
# Hook input (stdin): JSON with agent_type, tool_input.command, etc.
# Hook output: JSON with permissionDecision: "deny" to block, or exit 0 to allow.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  AGENT_TYPE=$(printf '%s' "$INPUT" | jq -r '.agent_type // empty')
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
else
  # jq is not installed. Fall back to a crude regex extraction from the raw JSON so the
  # guard fails CLOSED (still blocks destructive commands for subagents) instead of
  # silently allowing everything because both fields came back empty.
  AGENT_TYPE=$(printf '%s' "$INPUT" | grep -oE '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/^"agent_type"[[:space:]]*:[[:space:]]*"//; s/"$//')
  COMMAND=$(printf '%s' "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1 | sed -E 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//')
fi

# Allow main agent (no agent_type) — user's permission system handles that
if [ -z "$AGENT_TYPE" ]; then
  exit 0
fi

# Allow agents that legitimately need full Bash access (implementation, test execution)
# Note: task-group-implementer is NOT whitelisted — destructive commands are blocked
# to prevent rogue git stash/reset --hard from clobbering sibling implementers
# running in parallel waves.
case "$AGENT_TYPE" in
  test-suite-runner|docs-operator)
    exit 0
    ;;
esac

# Block destructive patterns for all other agents
if echo "$COMMAND" | grep -qEi 'git\s+stash|git\s+reset\s+--hard|git\s+checkout\s+--\s+\.|git\s+checkout\s+\.\s*$|git\s+clean|git\s+push\s+(-f|--force)|rm\s+-rf'; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked for agent '$AGENT_TYPE': ${COMMAND:0:80}"
  }
}
EOF
  exit 0
fi

exit 0
