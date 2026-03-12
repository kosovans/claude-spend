#!/bin/bash
# sync-cowork-macos.sh — Sync Cowork session data to the claude-spend dashboard.
# Run from macOS (Desktop Commander / scheduled task).
#
# Usage:
#   ./sync-cowork-macos.sh          # one-time sync
#   ./sync-cowork-macos.sh --watch  # background sync every 2 min

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$SCRIPT_DIR/cowork-data/projects"
SESSIONS_BASE="$HOME/Library/Application Support/Claude/local-agent-mode-sessions"

do_sync() {
  mkdir -p "$DEST"
  found=0
  for projects_dir in "$SESSIONS_BASE"/*/*/local_*/.claude/projects; do
    [ -d "$projects_dir" ] || continue
    rsync -a --update "$projects_dir/" "$DEST/"
    found=$((found + 1))
  done

  local count
  count=$(find "$DEST" -name "*.jsonl" | wc -l | tr -d ' ')
  local size
  size=$(du -sh "$DEST" 2>/dev/null | cut -f1)
  echo "$(date '+%H:%M:%S') — $count JSONL file(s) across $found session(s), $size total"
}

if [ "${1:-}" = "--watch" ]; then
  echo "Syncing every 120s (Ctrl+C to stop)..."
  do_sync
  while true; do sleep 120; do_sync; done &
  BGPID=$!
  echo "Background PID: $BGPID"
  echo "$BGPID" > /tmp/cowork-sync-macos.pid
  disown "$BGPID" 2>/dev/null
else
  do_sync
fi
