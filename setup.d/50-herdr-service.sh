#!/usr/bin/env bash
# herdr's server starts with the user session. Enable only: starting it here
# would compete with a server already running in this session.
set -euo pipefail
command -v systemctl >/dev/null || exit 0
systemctl --user is-enabled --quiet herdr 2>/dev/null || systemctl --user enable herdr
