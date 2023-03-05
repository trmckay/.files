export EDITOR='nvr -s --remote-wait'
export GIT_PAGER="delta"
export PAGER="bat --paging always --decorations never"

function preexec {
    if [[ -n "$TMUX" ]]; then
        eval "$(tmux show-environment -s)"
    fi
}
