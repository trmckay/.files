if command -v keychain > /dev/null 2>&1; then
    keychain -q id_rsa
    . ~/.keychain/`uname -n`-sh
fi
