#!/usr/bin/env bash
# setup-iterm2-autosave.sh - venv Python + LaunchAgent per il salvataggio
# periodico dell'arrangement iTerm2 (vedi `cheat iterm2-autosave`).
# Idempotente. Richiede uv (Brewfile) e gli script già linkati da link-dotfiles.sh.

set -euo pipefail

# TODO(tech-debt): missing tests for setup-iterm2-autosave (side effect su uv e launchctl)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="com.padipierro.iterm2-save-arrangement"
TEMPLATE="$SCRIPT_DIR/../launchd/$LABEL.plist"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
VENV="$HOME/.local/share/iterm2-save/venv"

# 1. venv con il modulo iterm2
if ! "$VENV/bin/python" -c 'import iterm2' 2>/dev/null; then
  echo ">> Creating iterm2 venv in $VENV..."
  uv venv --quiet --allow-existing "$VENV"
  uv pip install --quiet --python "$VENV/bin/python" iterm2
fi

# 2. LaunchAgent: launchd non espande ~ né $HOME, quindi il path è reso dal template
rendered=$(sed "s|__HOME__|$HOME|g" "$TEMPLATE")
if [[ ! -f "$PLIST" || "$rendered" != "$(<"$PLIST")" ]]; then
  echo ">> Installing LaunchAgent $LABEL..."
  mkdir -p "$(dirname "$PLIST")"
  printf '%s\n' "$rendered" > "$PLIST"
  launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$PLIST"
fi
