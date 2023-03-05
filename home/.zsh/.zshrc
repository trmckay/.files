source $ZDOTDIR/env.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/history.zsh
source $ZDOTDIR/completion.zsh
source $ZDOTDIR/keychain.zsh
source $ZDOTDIR/prompt.zsh
source $ZDOTDIR/plugins.zsh
source $ZDOTDIR/keybindings.zsh

if [[ -f "$ZDOTDIR/local_rc.zsh" ]]; then
    source $ZDOTDIR/local_rc.zsh
fi
