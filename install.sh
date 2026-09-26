#!/usr/bin/env bash
# install.sh - idempotent setup of brew packages from Brewfile_iliad
# Usage:
#   ./install.sh                           # uses Brewfile_iliad in same dir
#   BREWFILE=/path/to/Brewfile ./install.sh
#   ./install.sh --cleanup                 # also removes packages not in Brewfile (asks first)
#   ./install.sh --cleanup --yes           # same, without confirmation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${BREWFILE:-${SCRIPT_DIR}/Brewfile_iliad}"
CLEANUP=0
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    --cleanup) CLEANUP=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --help|-h)
      sed -n '2,7p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (see --help)" >&2
      exit 2
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
  # Official installer, fetched over HTTPS from Homebrew's GitHub repo
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for prefix in /opt/homebrew /usr/local; do
    [[ -x "$prefix/bin/brew" ]] && eval "$("$prefix/bin/brew" shellenv)" && break
  done
fi

# 2. Update + bundle
echo ">> Updating Homebrew..."
brew update

echo ">> Bundling from $BREWFILE..."
brew bundle install --file="$BREWFILE"

# 3. Optional cleanup (destructive: show what goes away, then confirm)
if [[ $CLEANUP -eq 1 ]]; then
  echo ">> Packages not in $BREWFILE:"
  pending=$(brew bundle cleanup --file="$BREWFILE" \
    | awk '/^Would uninstall/ { print; p=1; next } /^(Would|==>|Run )/ { p=0 } p')
  if [[ -n "$pending" ]]; then
    echo "$pending"
    if [[ $ASSUME_YES -eq 0 ]]; then
      if [[ ! -t 0 ]]; then
        echo "Not a terminal: re-run with --yes to confirm cleanup." >&2
        exit 1
      fi
      read -r -p "Uninstall them? [y/N] " answer
      [[ "$answer" =~ ^[yY]$ ]] || { echo ">> Cleanup skipped."; exit 0; }
    fi
    brew bundle cleanup --file="$BREWFILE" --force
  else
    echo "   none."
  fi
fi

echo ">> Done."
