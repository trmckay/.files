ZDOTDIR="$HOME/.zsh"

source "$ZDOTDIR/lib.zsh"

source_if_exists "$ZDOTDIR/local_env.zsh"
source_if_exists "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
