alias cdiff='diff --color=always'
alias cless='less -R'
alias d='docker'
alias dc='docker-compose'
alias df='df -h'
alias e='$EDITOR'
alias gdb='gdb -q'
alias git-cd-root='cd $(git rev-parse --show-toplevel)'
alias gv='vim +Git +only'
alias mkdir='mkdir -p'
alias nvim-clean='nvim -u ~/.vimrc --noplugin'
alias py='python3'
alias reset='reset; exec zsh'
alias se='sudoedit'
alias sudoe='sudo -E -H'
alias tma='tmux a -t'
alias tml='tmux ls'
alias utop='htop -u'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias cat='bat --decorations=never --paging=never'
alias less='bat --decorations=never --paging=always'

alias ls='exa'
alias la='exa -a'
alias ll='exa -lbFgUh --octal-permissions --time-style=long-iso'
alias lla='exa -albFgUh --octal-permissions --time-style=long-iso'
alias tree='exa --tree'

function cd {
   if ! builtin cd $@ 2>/dev/null; then
       z $@
   fi
}
