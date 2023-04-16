source "$ZDOTDIR/lib.zsh"

alias e='$EDITOR'
alias mkdir='mkdir -p'
alias cdiff='diff --color=always'
alias cless='less -R'

if command_exists gdb; then
    alias gdb='gdb -q'
fi

if command_exists python; then
    alias py='python'
    alias py3='python3'
fi

if command_exists sudo; then
    alias se='sudoedit'
    alias sudoe='sudo -E -H'
fi

if command_exists tmux; then
    alias tmn='tmux new-session -s'
    alias tma='tmux attach-session -t'
    alias tml='tmux ls'
fi

if command_exists htop; then
    alias utop='htop -u'
else
    alias utop='top -u $(whoami)'
fi

if command_exists nvim; then
    alias v='nvim'
    alias vi='nvim'
    alias vim='nvim'
    alias gv='nvim +Git +only'
fi

if command_exists bat; then
    alias cat='bat --decorations=never --paging=never'
    alias less='bat --decorations=never --paging=always'
fi

if command_exists exa; then
    alias ls='exa'
    alias la='exa -a'
    alias ll='exa -lbFgUh --octal-permissions --time-style=long-iso'
    alias lla='exa -albFgUh --octal-permissions --time-style=long-iso'
    alias tree='exa --tree'
fi

if command_exists zoxide; then
    function cd {
       if ! builtin cd $@ 2>/dev/null; then
           z $@
       fi
    }
fi

if command_exists nix; then
    function ns {
        pkg="$1"
        shift 1
        if [[ ! -z "$@" ]]; then
            nix shell nixpkgs#$pkg --command "$@"
        else
            nix shell nixpkgs#$pkg
        fi
    }
fi
