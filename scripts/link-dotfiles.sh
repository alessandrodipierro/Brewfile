#!/usr/bin/env bash
# link-dotfiles.sh - symlinka ogni file di home/ nello stesso path sotto $HOME
# Idempotente: i link già corretti non vengono toccati; un file esistente
# viene spostato in <file>.backup.<timestamp> prima di essere sostituito.
# Usage:
#   scripts/link-dotfiles.sh
#   DOTFILES_DIR=<dir> TARGET_HOME=<dir> scripts/link-dotfiles.sh   # (test)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/../home" && pwd)}"
TARGET_HOME="${TARGET_HOME:-$HOME}"
TS="$(date '+%Y%m%d-%H%M%S')"

# L'identità git vive in ~/.gitconfig.local (non versionato): se manca,
# la estrae dal ~/.gitconfig esistente prima che venga sostituito dal link.
migrate_git_identity() {
  local local_cfg="$TARGET_HOME/.gitconfig.local"
  local current="$TARGET_HOME/.gitconfig"
  local name="" email=""

  [[ -f "$local_cfg" ]] && return 0
  if [[ -f "$current" && ! -L "$current" ]]; then
    name=$(git config --file "$current" user.name || true)
    email=$(git config --file "$current" user.email || true)
  fi
  if [[ -z "$name" && -z "$email" ]]; then
    echo "!! $local_cfg mancante: imposta la tua identità git con" >&2
    echo "   git config --file ~/.gitconfig.local user.name  'Nome Cognome'" >&2
    echo "   git config --file ~/.gitconfig.local user.email 'nome@example.com'" >&2
    return 0
  fi
  [[ -n "$name" ]] && git config --file "$local_cfg" user.name "$name"
  [[ -n "$email" ]] && git config --file "$local_cfg" user.email "$email"
  echo "   git identity -> $local_cfg"
}

link_one() {
  local rel="$1"
  local src="$DOTFILES_DIR/$rel"
  local dst="$TARGET_HOME/$rel"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.backup.$TS"
    echo "   backup: $dst.backup.$TS"
  fi
  ln -s "$src" "$dst"
  echo "   linked: $dst"
}

echo ">> Linking dotfiles from $DOTFILES_DIR..."
migrate_git_identity
while IFS= read -r rel; do
  link_one "$rel"
done < <(cd "$DOTFILES_DIR" && find . -type f ! -name '.DS_Store' | sed 's|^\./||' | sort)
