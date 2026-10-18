#!/usr/bin/env bash
# Install the CLI tools named in ~/.config/mise/conf.d (claude, codex, gh,
# delta, herdr, ...). mise installs only what is missing, so reruns are quiet.
set -euo pipefail
command -v mise >/dev/null || { echo "mise not installed yet; skipped"; exit 0; }
mise install --yes
