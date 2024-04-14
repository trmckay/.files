source "$ZDOTDIR/lib.zsh"

if command_exists zoxide; then
    eval "$(zoxide init zsh)"
fi

ZSH_PLUGINS="$HOME/.zsh/plugins"

if [[ ! -d "$ZSH_PLUGINS" ]]; then
    mkdir -p "$ZSH_PLUGINS"
fi

# $1: git remote
# $2: commit hash
# $3: relative path to source
function source_git {
    plugin_name="$(basename $1)"
    repo_path="$ZSH_PLUGINS/$plugin_name"
    if [[ ! -d "$repo_path" ]]; then
        git clone "$1" "$repo_path"
    fi
    (cd "$repo_path" && git reset --hard > /dev/null) || return
    source "$repo_path/${3:-${plugin_name}.plugin.zsh}"
}

# 1: url to file to source
# 2: SHA256 checksum
function source_https {
    url="$1"
    script_path="$ZSH_PLUGINS/$(basename "$url")"
    if [[ ! -a "$script_path" ]]; then
        curl -fsSLo "$script_path" "$url"
    fi
    echo "$2 $script_path" | sha256sum -c --quiet || return
    source "$script_path"
}

source_git \
    "https://github.com/zsh-users/zsh-completions" \
    "820aaba911fce0594bf17f0e9a82092a6af7810e"

source_https \
    "https://raw.githubusercontent.com/junegunn/fzf/4603d540c3ae648c9e2ef84f33433b275290aa7c/shell/key-bindings.zsh" \
    "55572091278e4d64adda88e5ab7f15b6217bf6ce31b6f61d54179f4c3d634010"

source_git \
    "https://github.com/zsh-users/zsh-syntax-highlighting" \
    "754cefe0181a7acd42fdcb357a67d0217291ac47"
