#!/usr/bin/env bash
# YubiKey stack, then the card's keys, so ssh works before any private
# toolkit is cloned. Both steps are idempotent; see the scripts for detail.
set -euo pipefail
yubikey.setup
# Without the card, import cannot learn its keys; leave that for later
# rather than stop the rest of base's setup.
if ! gpg --card-status >/dev/null 2>&1; then
  echo "no YubiKey found: plug it in, then run yubikey.import"
  exit 0
fi
yubikey.import
