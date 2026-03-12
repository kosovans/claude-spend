#!/bin/bash
# sync-cowork.sh — Run inside a Cowork session to sync data to the dashboard.
#
# Usage:
#   ./sync-cowork.sh          # one-time sync
#   ./sync-cowork.sh --watch  # sync every 2 min in background
#
# Or paste this into any Cowork session:
#   bash /sessions/*/mnt/claude-spend/sync-cowork.sh --watch

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$SCRIPT_DIR/cowork-data/projects"

# Find Cowork session data inside the VM
SOURCE=""
for d in /sessions/*/mnt/.claude/projects; do
  [ -d "$d" ] && SOURCE="$d" && break
done

if [ -z "$SOURCE" ]; then
  echo "Not inside a Cowork VM (no session data found)."
  exit 1
fi

do_sync() {
  mkdir -p "$DEST"
  rsync -a --update "$SOURCE/" "$DEST/"
  local count
  count=$(find "$DEST" -name "*.jsonl" | wc -l | tr -d ' ')
  local size
  size=$(du -sh "$DEST" 2>/dev/null | cut -f1)
  echo "$(date '+%H:%M:%S') — $count session(s), $size"
}

if [ "${1:-}" = "--watch" ]; then
  echo "Syncing every 120s (Ctrl+C to stop)..."
  do_sync
  while true; do sleep 120; do_sync; done &
  BGPID=$!
  echo "Background PID: $BGPID"
  # Write PID so it can be stopped later
  echo "$BGPID" > /tmp/cowork-sync.pid
  disown "$BGPID" 2>/dev/null
else
  do_sync
fi
