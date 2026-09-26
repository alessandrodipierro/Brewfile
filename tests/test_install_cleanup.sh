#!/usr/bin/env bash
# Test di install.sh --cleanup con un `brew` finto nel PATH.
# Il brew reale esce con 1 dal dry-run di cleanup quando c'è qualcosa da
# rimuovere: install.sh non deve interrompersi lì.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

mkdir -p "$TMP/bin"
touch "$TMP/Brewfile"
cat > "$TMP/bin/brew" <<'EOF'
#!/usr/bin/env bash
echo "$*" >> "$BREW_LOG"
if [[ "$1 $2" == "bundle cleanup" ]]; then
  if [[ " $* " == *" --force "* ]]; then exit 0; fi
  [[ "${BREW_NOTHING_TO_CLEAN:-0}" == 1 ]] && exit 0
  printf 'Would uninstall formulae:\nfoo\nWould `brew cleanup`:\nRun `brew bundle cleanup --force` to make these changes.\n'
  exit 1
fi
exit 0
EOF
chmod +x "$TMP/bin/brew"

run_install() {
  PATH="$TMP/bin:$PATH" BREW_LOG="$TMP/brew.log" BREWFILE="$TMP/Brewfile" \
    "$ROOT/install.sh" --skip-dotfiles "$@" </dev/null
}

# pacchetti da rimuovere + --yes: mostra la lista e lancia cleanup --force
: > "$TMP/brew.log"
out=$(run_install --cleanup --yes)
[[ "$out" == *"foo"* ]] || fail "pending list not shown: $out"
[[ "$out" == *">> Done."* ]] || fail "install.sh stopped early: $out"
grep -q -- "bundle cleanup --file=$TMP/Brewfile --force" "$TMP/brew.log" || fail "cleanup --force not run"

# senza --yes e senza tty: si ferma senza rimuovere nulla
: > "$TMP/brew.log"
if run_install --cleanup >/dev/null 2>&1; then fail "expected abort without tty"; fi
! grep -q -- "--force" "$TMP/brew.log" || fail "cleanup --force run without confirmation"

# niente da rimuovere: nessun --force, termina normalmente
: > "$TMP/brew.log"
out=$(BREW_NOTHING_TO_CLEAN=1 run_install --cleanup --yes)
[[ "$out" == *"none."* && "$out" == *">> Done."* ]] || fail "empty cleanup not handled: $out"
! grep -q -- "--force" "$TMP/brew.log" || fail "cleanup --force run with nothing to clean"

echo "ok - install --cleanup"
