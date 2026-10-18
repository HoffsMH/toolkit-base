#!/usr/bin/env bash
# Folders every machine has, even when empty: code checkouts, and the
# folders under ~/personal that Syncthing shares between machines.
set -euo pipefail

for d in code/paid code/unpaid personal/00-cap-md personal/01-cap-storage; do
  mkdir -p "$HOME/$d"
done
