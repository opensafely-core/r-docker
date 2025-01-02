#!/bin/bash
set -euo pipefail

for link in $(find "$1" -type l)
do
    src=$(readlink "$link")
    echo "Copying $src to $link"
    rm "$link"
    cp -R "$src" "$link"
done
