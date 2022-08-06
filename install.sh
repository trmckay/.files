#!/usr/bin/env bash

set -euo pipefail

# Find every regular file in the dotfile directory. For each file, remove
# the corresponding file in $HOME if it exists, create any parent directories,
# then symlink it.

find . \
	-type f \
	-not -regex "./\.git/.*" \
	-not -name ".stylua.toml" \
	-not -name ".gitignore" \
	-not -name "install.sh" \
	-not -name "send.sh" \
	-printf "%P\0" |
	xargs -I "{}" -r0 bash -c '''
        rm -f "${HOME}/{}" && \
        mkdir -p "$(dirname "${HOME}/{}")" && \
        find "$(dirname "${HOME}/{}")" -maxdepth 1 -xtype l -print0 | xargs -r0 rm && \
        ln -svf "'$(realpath "$(dirname "$0")")'/{}" "${HOME}/{}"
    '''
