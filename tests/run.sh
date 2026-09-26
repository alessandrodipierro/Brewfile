#!/usr/bin/env bash
# Esegue tutti i tests/test_*.sh; esce con errore al primo che fallisce.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
for t in test_*.sh; do
  bash "$t"
done
