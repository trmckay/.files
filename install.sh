#!/usr/bin/env bash

# Find every regular file in the dotfile directory. For each file, remove
# the corresponding file in $HOME if it exists, create any parent directories,
# then symlink it.

set -euo pipefail
IFS=$'\n'

base_dir="home"

for file in $(find "$base_dir" -type f); do
    relative_path="$(realpath --relative-to "$base_dir" "$file")"
    relative_parent="$(dirname "$relative_path")"
    mkdir -p "$HOME/$relative_parent"
    ln -svf "$(realpath "$file")" "$HOME/$relative_path"
done
