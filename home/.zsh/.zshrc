source $ZDOTDIR/defaults.zsh
source $ZDOTDIR/completion.zsh
source $ZDOTDIR/preexec.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/history.zsh
source $ZDOTDIR/keychain.zsh
source $ZDOTDIR/prompt.zsh
source $ZDOTDIR/keybindings.zsh

localrc="$ZDOTDIR/zshrc-local.zsh"
if [[ -f "$localrc" ]]; then
    source "$localrc"
fi

source $ZDOTDIR/plugins.zsh
