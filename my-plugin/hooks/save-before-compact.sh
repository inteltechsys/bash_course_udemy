#!/bin/bash
# Hook PreCompact : copie la conversation avant qu'elle soit résumée
INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')
DEST="$CLAUDE_PROJECT_DIR/.claude/backups/sauvegarde-avant-compact-$(date +%Y%m%d-%H%M%S).txt"

mkdir -p "$(dirname "$DEST")"
cp "$TRANSCRIPT" "$DEST"
exit 0
