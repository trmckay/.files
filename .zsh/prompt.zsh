autoload -Uz vcs_info

export VIRTUAL_ENV_DISABLE_PROMPT=1

export ZSH_LAST_EXIT=0

precmd() {
    export ZSH_LAST_EXIT=$?
    echo
    vcs_info
    if [[ "$(pwd)" == "$HOME" ]]; then
        print -Pn "\e]0;zsh - $(whoami)@$(hostname -s)\a"
    else
        print -Pn "\e]0;zsh - $(whoami)@$(hostname -s):$(basename "$(pwd)")\a"
    fi
}

zstyle ':vcs_info:*' formats '[%F{red}%b%f] '
zstyle ':vcs_info:*' actionformats '[%F{red}%b %a%f] '

set -o promptsubst

NL=$'\n'

function _pwd {
    if [[ "$PWD" == "$HOME" ]]; then
        echo "~"
    else
        echo "${PWD#"$HOME"/}"
    fi
}

function _exit_code {
    echo "%(?..%F{magenta}\$? == $ZSH_LAST_EXIT%f )"
}

prompt='[%F{cyan}%n@%m%f:%F{blue}$(_pwd)%f] $vcs_info_msg_0_$(_exit_code)${NL}%# '
