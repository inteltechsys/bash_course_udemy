#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')
if echo "$COMMAND" | grep -qE 'git push.*main'; then
  echo "Bloqué : push sur main interdit." >&2
  exit 2
fi
exit 0
