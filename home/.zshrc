# One copy of each PATH entry, even in nested shells.
typeset -U path PATH
source "$HOME/.zsh/functions_and_aliases.sh"

# Tool init (skip silently if a tool isn't installed)
command -v mise     >/dev/null && eval "$(mise activate zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v direnv   >/dev/null && eval "$(direnv hook zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v atuin    >/dev/null && eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"

# zsh plugins (Arch package paths)
[[ -r /usr/share/zsh/plugins/zsh-autopair/autopair.plugin.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autopair/autopair.plugin.zsh
[[ -r /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && \
    source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# herdr's server can be started from a tty, so panes it spawns inherit no
# WAYLAND_DISPLAY and wl-copy (and with it nvim's clipboard) silently no-ops.
if [[ -z $WAYLAND_DISPLAY && -n $XDG_RUNTIME_DIR ]]; then
  for _wl in $XDG_RUNTIME_DIR/wayland-*(N=); do
    export WAYLAND_DISPLAY=${_wl:t}
    break
  done
  unset _wl
fi

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

# PATH
export PATH=$HOME/bin:$HOME/.local/bin:$PATH

# asdf-managed languages (Go, Node, etc.)
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Go-installed binaries (paste-cb, gh-clone-org, etc.)
export PATH=$HOME/go/bin:$PATH

bindkey -e
bindkey '^e' edit_command
bindkey '^g' edit_command
# Ghostty pastes on ctrl+v and passes the key through; quoted-insert would eat the paste.
bindkey -r '^V'

command -v fastfetch >/dev/null && fastfetch

# Pieces shipped by other toolkits, in name order. (N): no error when empty.
for f in ~/.zsh/rc.d/*.zsh(N); do source "$f"; done
