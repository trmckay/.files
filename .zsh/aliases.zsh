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
alias v='NVIM_NOWAIT=1 vmux'
alias vi='NVIM_NOWAIT=1 vmux'
alias vim='NVIM_NOWAIT=1 vmux'

if command -v bat 2>&1 > /dev/null; then
    alias cat='bat --decorations=never --paging=never'
    alias less='bat --decorations=never --paging=always'
fi

if command -v exa 2>&1 > /dev/null; then
    alias ls='exa'
    alias la='exa -a'
    alias ll='exa -lbFgUh --octal-permissions --time-style=long-iso'
    alias lla='exa -albFgUh --octal-permissions --time-style=long-iso'
    alias tree='exa --tree'
else
    unalias ls
    alias la='ls -a'
    alias ll='ls -lbFgUh'
    alias lla='ls -albFgUh'
fi

if command -v fzf 2>&1 >/dev/null; then
    function gs {
        git switch $(
            git branch -a -vv --color=always | grep -v '/HEAD\s' |
                fzf --height 40% --ansi --multi --tac | sed 's/^..//' | awk '{print $1}' |
                sed 's#^remotes/[^/]*/##'
        )
    }

    function gfh {
        git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph |
            fzf --height 40% --ansi --no-sort --reverse --multi | grep -o '[a-f0-9]\{7,\}'
    }

    function tmf {
        if tmux ls 2>/dev/null; then
            session=$(tmux ls | fzf | cut -d':' -f1)
            if [ "$session" != "" ]; then
                tmux attach-session -t "$session"
            fi
        fi
    }
fi

function tmn {
    if [ "$1" ]; then
        tmux new-session -A -s "$@"
    else
        tmux new-session -A -s "$(basename $(pwd))"
    fi
}

function pwait {
    while pgrep "$1" >/dev/null; do
        sleep 1
    done
}

if command -v zoxide 2>&1 >/dev/null; then
    function cd {
       if ! builtin cd $@ 2>/dev/null; then
            z $@
        fi
    }
fi

function retry {
    while ! $@; do
        sleep 1
    done
}

function rm-dead-links {
    find "$1" -xtype -l -print0 | xargs -r0 unlink
}
