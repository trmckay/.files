export ZSH_LAST_EXIT=0
function _component_exit_code {
    echo "%(?..[%F{magenta}$ZSH_LAST_EXIT%f] )"
}

function _component_ssh {
    if [[ ! -z $SSH_CLIENT ]]; then
        echo "[%F{green}ssh: $(echo $SSH_CLIENT | cut -d' ' -f 1)%f] "
    fi
}

function _component_machine {
    function _pwd {
        if [[ "$PWD" == "$HOME" ]]; then
            echo "~"
        else
            echo "${PWD#"$HOME"/}"
        fi
    }
    echo "[%F{cyan}%n@%m%f:%F{blue}$(_pwd)%f] "
}

autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '[%F{red}%b%f] '
zstyle ':vcs_info:*' actionformats '[%F{red}%b %a%f] '
function _component_vcs {
    echo "$vcs_info_msg_0_"
}

function _component_symbol {
    echo "\n%# "
}

precmd() {
    export ZSH_LAST_EXIT=$?
    echo
    vcs_info
}

export VIRTUAL_ENV_DISABLE_PROMPT=1

set -o promptsubst

prompt='''\
$(_component_machine)\
$(_component_ssh)\
$(_component_vcs)\
$(_component_exit_code)\
$(_component_symbol)\
'''
