# One copy of each PATH entry, even in nested shells.
typeset -U path PATH
# Homebrew (macOS) before the tool checks below; its bin then wins over the
# system's, even after /etc/zprofile's path_helper reordered PATH.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
source "$HOME/.zsh/functions_and_aliases.sh"

# Tool init (skip silently if a tool isn't installed)
command -v mise     >/dev/null && eval "$(mise activate zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v direnv   >/dev/null && eval "$(direnv hook zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v atuin    >/dev/null && eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"

# zsh plugins (Arch package paths, then Homebrew's)
for _p in \
  /usr/share/zsh/plugins/zsh-autopair/autopair.plugin.zsh \
  /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  $HOMEBREW_PREFIX/share/zsh-autopair/autopair.zsh \
  $HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh; do
  [[ -r $_p ]] && source $_p
done
unset _p

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
# Linux starts gpg-agent from a systemd socket; macOS has nothing that does,
# so ssh would find no agent behind the socket.
[[ $OSTYPE == darwin* ]] && gpgconf --launch gpg-agent

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
