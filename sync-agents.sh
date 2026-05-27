#!/bin/bash
set -e

SRC="$HOME/.claude/agents/"
DEST="$HOME/claude-agents/"

rsync -av "$SRC" "$DEST" --exclude='.git'

cd "$DEST"
git add -A

if git diff --cached --quiet; then
  echo "No changes to sync."
else
  git commit -m "Auto-sync agents $(date +%Y-%m-%d)"
  git push
fi
