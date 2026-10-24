#!/bin/bash
# Hook PostToolUse : lance shellcheck sur le fichier que Claude vient d'écrire
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path')

# On ne contrôle que les scripts Bash (première ligne = #!/bin/bash)
if [ -f "$FILE" ] && [ "$(head -n 1 "$FILE")" = "#!/bin/bash" ]; then
  if ! RESULT=$(shellcheck "$FILE" 2>&1); then
    echo "shellcheck a trouvé des problèmes dans $FILE :" >&2
    echo "$RESULT" >&2
    exit 2
  fi
fi
exit 0
