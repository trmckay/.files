if command -v keychain > /dev/null 2>&1; then
    keychain -q id_rsa
    . ~/.keychain/`uname -n`-sh
fi

function tmux_upd_env() {
  if [[ -n "$TMUX" ]]; then
    eval "$(tmux show-environment -s)"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd tmux_upd_env
