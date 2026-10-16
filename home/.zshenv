# Every zsh reads this, including the non-interactive shell ssh runs a command
# in (herdr --remote starts its server that way). vi is not installed; keep
# Omarchy's value in graphical sessions.
export EDITOR="${EDITOR:-nvim}" VISUAL="${VISUAL:-nvim}"
