function preexec {
    if [[ -n "$TMUX" ]]; then
        eval "$(tmux show-environment -s)"
    fi
}
