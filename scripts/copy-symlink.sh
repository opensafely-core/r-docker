#!/bin/bash
set -euo pipefail

while IFS= read -r -d '' link
do
    src=$(readlink "$link")
    echo "Copying $src to $link"
    rm "$link"
    cp -R "$src" "$link"
done < <(find "$1" -type l -print0)
