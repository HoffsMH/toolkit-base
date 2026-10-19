#!/usr/bin/env bash
# Logged in to the tailnet, and MagicDNS resolves closet, where private
# toolkits are cloned from.
set -uo pipefail
fail=0

# The macOS app keeps its CLI inside the bundle unless brew linked one.
ts=tailscale
command -v tailscale >/dev/null || ts=/Applications/Tailscale.app/Contents/MacOS/Tailscale

# macOS has no getent; dscacheutil asks the same resolver apps use.
resolves() {
  if command -v getent >/dev/null; then getent hosts "$1"
  else dscacheutil -q host -a name "$1" | grep -q '^ip_address'; fi
}

if "$ts" status --peers=false >/dev/null 2>&1; then
  echo "ok   logged in to tailnet"
else
  echo "FAIL not logged in (run: sudo tailscale up)"; fail=1
fi

if resolves closet >/dev/null; then
  echo "ok   closet resolves"
else
  echo "FAIL closet does not resolve (MagicDNS off?)"; fail=1
fi
exit $fail
