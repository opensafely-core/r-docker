#!/bin/bash
set -eu
IMAGE=${1:-ghcr.io/opensafely/r}
tests=$(grep -v '^#' packages.txt | xargs -L1 -I {} echo "library(\"{}\", warn.conflicts = FALSE)")
docker run $IMAGE -e "$tests"
