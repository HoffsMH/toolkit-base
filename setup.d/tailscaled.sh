#!/usr/bin/env bash
# On macOS the Tailscale app runs its own daemon, so there is nothing to enable.
set -euo pipefail

[ "$(/usr/bin/uname)" = Linux ] || exit 0

if systemctl is-enabled --quiet tailscaled && systemctl is-active --quiet tailscaled; then
  echo "tailscaled already enabled and running"
  exit 0
fi
sudo systemctl enable --now tailscaled
