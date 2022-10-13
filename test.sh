#!/bin/bash
set -eu
IMAGE=${1:-ghcr.io/opensafely-core/r}
tests=$(grep -v '^#' packages.txt | awk '{ print $1 }' | xargs -L1 -I {} echo "library(\"{}\", warn.conflicts = FALSE)")
docker run --rm "$IMAGE" -e "$tests"
