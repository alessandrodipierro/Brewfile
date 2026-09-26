#!/usr/bin/env bash
# Salva l'arrangement iTerm2 "Work" se iTerm2 è in esecuzione.
# Mantiene gli ultimi N backup dell'arrangement prima di sovrascrivere.

set -euo pipefail

BACKUP_DIR="$HOME/.local/share/iterm2-arrangement-backups"
LOG="$HOME/Library/Logs/iterm2-arrangement-save.log"
PYTHON="$HOME/.local/share/iterm2-save/venv/bin/python"
SCRIPT="$HOME/.local/share/iterm2-save/save_arrangement.py"
KEEP_BACKUPS=20

mkdir -p "$BACKUP_DIR" "$(dirname "$LOG")"

TS=$(date '+%Y-%m-%d_%H-%M-%S')

# Skip se iTerm2 non sta girando
RUNNING=$(/usr/bin/osascript -e 'tell application "System Events" to (count of (every process whose bundle identifier is "com.googlecode.iterm2"))' 2>/dev/null || echo 0)
if [ "$RUNNING" -eq 0 ]; then
  exit 0
fi

# Backup arrangement corrente (pre-save), con rotazione
if defaults read com.googlecode.iterm2 "Window Arrangements" >/dev/null 2>&1; then
  defaults read com.googlecode.iterm2 "Window Arrangements" > "$BACKUP_DIR/Work.$TS.plist" 2>/dev/null || true
  ls -t "$BACKUP_DIR"/Work.*.plist 2>/dev/null | tail -n +$((KEEP_BACKUPS + 1)) | xargs -I {} rm {} 2>/dev/null || true
fi

# Save via Python API
if "$PYTHON" "$SCRIPT" 2>>"$LOG"; then
  echo "$TS  saved arrangement 'Work'" >> "$LOG"
  EXIT_CODE=0
else
  echo "$TS  FAILED to save arrangement 'Work'" >> "$LOG"
  EXIT_CODE=1
fi

# Log rotation (>1MB)
LOG_SIZE=$(stat -f%z "$LOG" 2>/dev/null || echo 0)
if [ "$LOG_SIZE" -gt 1048576 ]; then
  mv "$LOG" "${LOG}.old"
fi

exit $EXIT_CODE
