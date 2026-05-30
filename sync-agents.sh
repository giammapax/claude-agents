#!/bin/bash
set -e

SRC="$HOME/.claude/agents/"
DEST="$HOME/claude-agents/"

rsync -av "$SRC" "$DEST" --exclude='.git'

cd "$DEST"
git add -A

# SAFETY GUARD: mai pushare vps-configs/segreti su GitHub (vedi regola di sicurezza)
STAGED="$(git diff --cached --name-only)"
if echo "$STAGED" | grep -Eiq 'vps[-_]config|id_ed25519|id_rsa|\.pem$|\.key$|secret'; then
  echo "ABORT: rilevati file vps-config/segreti in stage, push annullato:"
  echo "$STAGED" | grep -Ei 'vps[-_]config|id_ed25519|id_rsa|\.pem$|\.key$|secret'
  git reset >/dev/null 2>&1
  exit 1
fi

if git diff --cached --quiet; then
  echo "No changes to sync."
else
  git commit -m "Auto-sync agents $(date +%Y-%m-%d)"
  git push
fi
