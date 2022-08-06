bindkey -e

autoload -z edit-command-line
zle -N edit-command-line

bindkey "^X^E" edit-command-line

if [[ -f ~/.zsh/fzf.zsh ]]; then
    source ~/.zsh/fzf.zsh
fi
