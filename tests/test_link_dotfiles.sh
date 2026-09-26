#!/usr/bin/env bash
# Test di scripts/link-dotfiles.sh su una home fittizia.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LINK="$ROOT/scripts/link-dotfiles.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

export DOTFILES_DIR="$TMP/dotfiles"
export TARGET_HOME="$TMP/home"
mkdir -p "$DOTFILES_DIR/.config/tool" "$TARGET_HOME"
echo "new zshrc" > "$DOTFILES_DIR/.zshrc"
echo "key = 1" > "$DOTFILES_DIR/.config/tool/config.toml"
printf '[include]\n\tpath = ~/.gitconfig.local\n' > "$DOTFILES_DIR/.gitconfig"
touch "$DOTFILES_DIR/.DS_Store"

# stato preesistente: file reali, gitconfig con identità
echo "old zshrc" > "$TARGET_HOME/.zshrc"
printf '[user]\n\tname = Jane Doe\n\temail = jane@example.com\n' > "$TARGET_HOME/.gitconfig"

"$LINK" >/dev/null

# symlink creati, anche in directory annidate
for rel in .zshrc .config/tool/config.toml .gitconfig; do
  [[ -L "$TARGET_HOME/$rel" ]] || fail "$rel is not a symlink"
  [[ "$(readlink "$TARGET_HOME/$rel")" == "$DOTFILES_DIR/$rel" ]] || fail "$rel points to the wrong file"
done
[[ ! -e "$TARGET_HOME/.DS_Store" ]] || fail ".DS_Store should not be linked"

# i file sostituiti restano come backup
backup=$(ls "$TARGET_HOME"/.zshrc.backup.*)
[[ "$(<"$backup")" == "old zshrc" ]] || fail "backup content lost"

# identità git migrata in ~/.gitconfig.local
[[ "$(git config --file "$TARGET_HOME/.gitconfig.local" user.email)" == "jane@example.com" ]] \
  || fail "git email not migrated"
[[ "$(git config --file "$TARGET_HOME/.gitconfig.local" user.name)" == "Jane Doe" ]] \
  || fail "git name not migrated"

# seconda esecuzione: nessun nuovo link né backup (idempotente)
before=$(find "$TARGET_HOME" -name '*.backup.*' | wc -l)
out=$("$LINK")
after=$(find "$TARGET_HOME" -name '*.backup.*' | wc -l)
[[ "$before" == "$after" ]] || fail "second run created new backups"
[[ "$out" != *"linked:"* ]] || fail "second run re-linked files: $out"

# home senza identità git → avviso, nessun errore
rm -rf "$TARGET_HOME" && mkdir -p "$TARGET_HOME"
err=$("$LINK" 2>&1 >/dev/null)
[[ "$err" == *".gitconfig.local mancante"* ]] || fail "missing identity warning not shown"

echo "ok - link-dotfiles"
