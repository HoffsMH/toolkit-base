#!/usr/bin/env bash
# Make zsh the login shell, since base ships the zsh config. macOS already
# defaults to zsh. sudo, so the password typed for pacman covers it too.
set -euo pipefail

[ "$(uname)" = Linux ] || exit 0
zsh=$(command -v zsh)
[ "$(getent passwd "$USER" | cut -d: -f7)" = "$zsh" ] && exit 0
sudo chsh -s "$zsh" "$USER"
echo "login shell is now $zsh (takes effect at next login)"
