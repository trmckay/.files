source "$ZDOTDIR/lib.zsh"

if command_exists nvim; then
    export EDITOR='nvim'
fi

if command_exists delta; then
    export GIT_PAGER="delta"
fi

if command_exists bat; then
    export PAGER="bat --paging always --decorations never"
fi
