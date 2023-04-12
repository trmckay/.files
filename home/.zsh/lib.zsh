function source_if_exists {
    if [[ -f "$1" ]]; then
        source "$1"
    fi
}

function command_exists {
    command -v $1 2>&1 >/dev/null
}
