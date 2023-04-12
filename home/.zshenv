ZDOTDIR="$HOME/.zsh"

local_env="$ZDOTDIR/local_env.zsh"

if [[ -f "$local_env" ]]; then
    source "$local_env"
fi
