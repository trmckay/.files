source "$ZDOTDIR/lib.zsh"

alias e='$EDITOR'
alias mkdir='mkdir -p'
alias cdiff='diff --color=always'
alias cless='less -R'

function cplink {
    dest="$(readlink "$1")"
    rm "$1"
    cp "$dest" "$1"
}

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
    alias tml='tmux ls'
    function tmn {
        exec tmux new-session -A -s "${1:-$(basename $(pwd))}"
    }
    if command_exists fzf; then
        function tma {
            session="${1:-$(tmux ls | fzf | cut -d':' -f1)}"
            if [[ ! -z $session ]]; then
                exec tmux attach-session -t "$session"
            fi
        }
    else
        alias tma='tmux attach-session -t'
    fi
    if command_exists fd && \
        command_exists fzf && \
        command_exists nvim;
    then
        function tv {
            cd "$1" && \
                tmux new-session -s "${2-$(basename $(git -C "$1" branch --show-current || pwd))}" nvim
        }
    fi
fi

if command_exists htop; then
    alias utop='htop -u'
else
    alias utop='top -u $(whoami)'
fi

if command_exists nvim; then
    function _nvim {
        if [[ -z $NVIM ]]; then
            nvim "$@"
        else
            echo "Refusing to nest nvim"
        fi
    }
    alias v='_nvim'
    alias vi='_nvim'
    alias vim='_nvim'
    alias gv='_nvim +Git +only'
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
    alias nd='nix develop --command zsh'
    alias nfu='nix flake update'
    alias nrb='sudo nixos-rebuild'
    alias nrbs='nrb switch'
    alias nrbb='nrb boot'
    alias nrbd='nrb dry-build'
fi
