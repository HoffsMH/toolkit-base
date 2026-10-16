#!/usr/bin/env bash
# YubiKey stack, then the card's keys, so ssh works before any private
# toolkit is cloned. Both steps are idempotent; see the scripts for detail.
set -euo pipefail
yubikey.setup
yubikey.import
