if [[ -f "$ZDOTDIR/pre.zsh" ]]; then
    source $ZDOTDIR/pre.zsh
fi

source $ZDOTDIR/env.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/history.zsh
source $ZDOTDIR/completion.zsh
source $ZDOTDIR/keychain.zsh
source $ZDOTDIR/prompt.zsh
source $ZDOTDIR/plugins.zsh
source $ZDOTDIR/keybindings.zsh

if [[ -f "$ZDOTDIR/post.zsh" ]]; then
    source $ZDOTDIR/post.zsh
fi
