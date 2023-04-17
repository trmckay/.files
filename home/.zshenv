ZDOTDIR="$HOME/.zsh"

source "$ZDOTDIR/lib.zsh"

source_if_exists "$ZDOTDIR/zshenv-local.zsh"
source_if_exists "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
