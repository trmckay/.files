if command -v zoxide 2>&1 >/dev/null; then
    eval "$(zoxide init zsh)"
fi

ZSH_PLUGINS="$HOME/.zsh/plugins"

if [[ ! -d "$ZSH_PLUGINS" ]]; then
    mkdir -p "$ZSH_PLUGINS"
fi

function plugin {
    repo="$ZSH_PLUGINS/$(basename $1)"
    if [[ ! -d "$repo" ]]; then
        echo "Installing plugin '$repo'"
        git clone "$1" "$repo"
    fi
    source "$repo/$2"
}

plugin "https://github.com/mdumitru/git-aliases" "git-aliases.zsh"
plugin "https://github.com/zsh-users/zsh-completions" "zsh-completions.plugin.zsh"
plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting.plugin.zsh"
plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions.plugin.zsh"
