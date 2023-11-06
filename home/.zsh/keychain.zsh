if command -v keychain > /dev/null 2>&1 && [[ -z $SSH_AUTH_SOCK ]]; then
    keychain -q id_rsa
    . ~/.keychain/`uname -n`-sh
fi
