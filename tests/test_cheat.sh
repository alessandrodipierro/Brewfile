#!/usr/bin/env bash
# Test di home/.local/bin/cheat su un cheatsheet fittizio.
# L'output è catturato (non tty), quindi cheat stampa markdown puro.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHEAT="$ROOT/home/.local/bin/cheat"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export CHEATSHEET="$TMP/sheet.md"
cat > "$CHEATSHEET" <<'EOF'
# Test sheet

Usage line that mentions rebase

## git
| Cosa | Come |
|---|---|
| Rebase | `git rebase` |
| Push | `git push` |

## mise — gestore versioni
| Cosa | Come |
|---|---|
| Lista | `mise ls` |
| Rebase finto | `mise rebase` |
EOF

fail() { echo "FAIL: $*" >&2; exit 1; }
contains() { [[ "$1" == *"$2"* ]] || fail "expected '$2' in output:"$'\n'"$1"; }
lacks() { [[ "$1" != *"$2"* ]] || fail "unexpected '$2' in output:"$'\n'"$1"; }

# --list: solo le chiavi (prima parola del titolo)
out=$("$CHEAT" --list)
[[ "$out" == $'git\nmise' ]] || fail "--list got: $out"

# sezione per chiave, case-insensitive, titolo con descrizione
out=$("$CHEAT" MISE)
contains "$out" "## mise — gestore versioni"
contains "$out" "mise ls"
lacks "$out" "git push"

# nessuna sezione → ricerca: righe raggruppate per sezione, con header tabella
out=$("$CHEAT" rebase)
contains "$out" "## git"
contains "$out" "git rebase"
contains "$out" "## mise"
contains "$out" "mise rebase"
contains "$out" "| Cosa | Come |"
lacks "$out" "git push"
lacks "$out" "Usage line"

# più parole = una sola query
out=$("$CHEAT" rebase finto)
contains "$out" "mise rebase"
lacks "$out" "git rebase"

# niente di trovato → exit 1 + messaggio su stderr
if err=$("$CHEAT" nonexistent 2>&1); then fail "expected non-zero exit"; fi
contains "$err" "nessuna sezione o riga per 'nonexistent'"

# senza argomenti → file intero
out=$("$CHEAT")
[[ "$out" == "$(<"$CHEATSHEET")" ]] || fail "full sheet differs"

# cheatsheet mancante → exit 1
if CHEATSHEET="$TMP/missing.md" "$CHEAT" git 2>/dev/null; then fail "expected failure on missing sheet"; fi

echo "ok - cheat"
