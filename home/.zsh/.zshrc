source $ZDOTDIR/env.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/history.zsh
source $ZDOTDIR/completion.zsh
source $ZDOTDIR/keychain.zsh
source $ZDOTDIR/prompt.zsh
source $ZDOTDIR/plugins.zsh
source $ZDOTDIR/keybindings.zsh

local_rc="$ZDOTDIR/local_rc.zsh"

if [[ -f "$local_rc" ]]; then
    source "$local_rc"
fi
