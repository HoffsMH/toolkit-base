#!/usr/bin/env bash
# Logged in to the tailnet, and MagicDNS resolves closet, where private
# toolkits are cloned from.
set -uo pipefail
fail=0

if tailscale status --peers=false >/dev/null 2>&1; then
  echo "ok   logged in to tailnet"
else
  echo "FAIL not logged in (run: sudo tailscale up)"; fail=1
fi

if getent hosts closet >/dev/null; then
  echo "ok   closet resolves"
else
  echo "FAIL closet does not resolve (MagicDNS off?)"; fail=1
fi
exit $fail
