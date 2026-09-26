#!/usr/bin/env bash
# install.sh - idempotent setup of brew packages from Brewfile_iliad
# Usage:
#   ./install.sh                           # uses Brewfile_iliad in same dir
#   BREWFILE=/path/to/Brewfile ./install.sh
#   ./install.sh --cleanup                 # also removes packages no longer in Brewfile

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${BREWFILE:-${SCRIPT_DIR}/Brewfile_iliad}"
CLEANUP=0

for arg in "$@"; do
  case "$arg" in
    --cleanup) CLEANUP=1 ;;
    --help|-h)
      sed -n '2,7p' "$0"
      exit 0
      ;;
  esac
done

if [[ ! -f "$BREWFILE" ]]; then
  echo "Brewfile not found: $BREWFILE" >&2
  exit 1
fi

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo ">> Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Update + bundle
echo ">> Updating Homebrew..."
brew update

echo ">> Bundling from $BREWFILE..."
brew bundle install --file="$BREWFILE"

# 3. Optional cleanup
if [[ $CLEANUP -eq 1 ]]; then
  echo ">> Cleaning up packages not in $BREWFILE..."
  brew bundle cleanup --file="$BREWFILE" --force
fi

echo ">> Done."
