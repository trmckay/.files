eval "$(zoxide init zsh)"

ZSH_PLUGINS="$HOME/.zsh/plugins"

if [[ ! -d "$ZSH_PLUGINS" ]]; then
    mkdir -p "$ZSH_PLUGINS"
fi

# $1: git remote
# $2: commit hash
# $3: relative path to source
function fetch_git {
    repo="$ZSH_PLUGINS/$(basename $1)"
    if [[ ! -d "$repo" ]]; then
        set -x
        git clone "$1" "$repo"
        set +x
    fi
    (cd "$repo" && git reset --hard > /dev/null) || return
    source "$repo/$3"
}

# 1: url to file to source
# 2: SHA256 checksum
function fetch_https {
    url="$1"
    script_path="$ZSH_PLUGINS/$(basename "$url")"
    if [[ ! -a "$script_path" ]]; then
        set -x
        curl -fsSLo "$script_path" "$url"
        set +x
    fi
    echo "$2 $script_path" | sha256sum -c --quiet || return
    source "$script_path"
}

fetch_git \
    "https://github.com/mdumitru/git-aliases" \
    "c4cfe2cf5cf59a3da6bf3b735a20921a2c06c58d" \
    "git-aliases.zsh"

fetch_git \
    "https://github.com/zsh-users/zsh-completions" \
    "820aaba911fce0594bf17f0e9a82092a6af7810e" \
    "zsh-completions.plugin.zsh"

fetch_git \
    "https://github.com/zsh-users/zsh-syntax-highlighting" \
    "754cefe0181a7acd42fdcb357a67d0217291ac47" \
    "zsh-syntax-highlighting.plugin.zsh"

fetch_git \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "a411ef3e0992d4839f0732ebeb9823024afaaaa8" \
    "zsh-autosuggestions.plugin.zsh"

fetch_https \
    "https://raw.githubusercontent.com/junegunn/fzf/4603d540c3ae648c9e2ef84f33433b275290aa7c/shell/key-bindings.zsh" \
    "55572091278e4d64adda88e5ab7f15b6217bf6ce31b6f61d54179f4c3d634010"
