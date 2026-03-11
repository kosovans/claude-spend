#!/bin/bash
# sync-cowork.sh — Syncs Cowork session data to claude-spend/cowork-data/
# Run this inside a Cowork VM to keep the dashboard up to date.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$SCRIPT_DIR/cowork-data/projects"

# Find Cowork session data inside the VM
SOURCE=""
if [ -d /sessions ]; then
  for d in /sessions/*/mnt/.claude/projects; do
    if [ -d "$d" ]; then
      SOURCE="$d"
      break
    fi
  done
fi

if [ -z "$SOURCE" ]; then
  echo "No Cowork session data found in /sessions/*/mnt/.claude/projects/"
  exit 1
fi

mkdir -p "$DEST"
rsync -a --update "$SOURCE/" "$DEST/"

# Count what we synced
FILE_COUNT=$(find "$DEST" -name "*.jsonl" | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh "$DEST" 2>/dev/null | cut -f1)
echo "$(date '+%H:%M:%S') — Synced $FILE_COUNT session(s), $TOTAL_SIZE total"
