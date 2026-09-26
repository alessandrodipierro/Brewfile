#!/usr/bin/env bash
# Restore di un arrangement iTerm2 da un backup precedente.
# Usage:
#   iterm2-restore-arrangement.sh                        # picker fzf
#   iterm2-restore-arrangement.sh <path-to-backup.plist> # restore diretto

set -euo pipefail

BACKUP_DIR="$HOME/.local/share/iterm2-arrangement-backups"

# 1. iTerm2 deve essere chiuso (al quit sovrascrive il plist con lo stato corrente)
RUNNING=$(/usr/bin/osascript -e 'tell application "System Events" to (count of (every process whose bundle identifier is "com.googlecode.iterm2"))' 2>/dev/null || echo 0)
if [ "$RUNNING" -ne 0 ]; then
  echo "iTerm2 è in esecuzione. Chiudilo prima del restore (Cmd+Q in iTerm2)." >&2
  echo "Lancia questo script da un'altra app terminale (es. Terminal.app)." >&2
  exit 1
fi

# 2. Seleziona il backup
if [ $# -ge 1 ]; then
  BACKUP="$1"
else
  if ! command -v fzf >/dev/null; then
    echo "fzf non installato. Passa il path al backup come argomento." >&2
    echo "Backup disponibili in: $BACKUP_DIR" >&2
    exit 1
  fi
  BACKUP=$(ls -t "$BACKUP_DIR"/Work.*.plist 2>/dev/null | fzf --prompt="Restore from: " --height=40% --reverse)
fi

[ -z "${BACKUP:-}" ] && { echo "Nessun backup selezionato." >&2; exit 1; }
[ ! -f "$BACKUP" ]   && { echo "File non trovato: $BACKUP" >&2; exit 1; }

echo "→ Restore da: $BACKUP"

# 3. Safety backup dello stato attuale prima di sovrascrivere
SAFETY="$BACKUP_DIR/Work.before-restore.$(date '+%Y-%m-%d_%H-%M-%S').plist"
defaults read com.googlecode.iterm2 "Window Arrangements" > "$SAFETY" 2>/dev/null || true
echo "→ Stato corrente salvato in: $SAFETY"

# 4. Restore: sovrascrive la chiave "Window Arrangements"
defaults write com.googlecode.iterm2 "Window Arrangements" "$(cat "$BACKUP")"
echo "✓ Restore completato. Riapri iTerm2."
