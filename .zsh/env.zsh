export EDITOR="$HOME/.local/bin/vmux"

if command -v delta 2>&1 > /dev/null; then
    export GIT_PAGER="delta"
fi

if command -v bat 2>&1 > /dev/null; then
    export PAGER="bat --paging always --decorations never"
fi

function preexec {
    if [[ -n "$TMUX" ]]; then
        eval "$(tmux show-environment -s)"
    fi
}

export NVIM_NOWAIT=0
