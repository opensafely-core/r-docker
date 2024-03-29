#!/usr/bin/env bash
set -eu
IMAGE=${1:-ghcr.io/opensafely-core/r}
python3 -c 'import json; print("\n".join(json.load(open("renv.lock"))["Packages"]))' | xargs -I {} echo "library({}, warn.conflicts = FALSE)" > .tests.R
docker run --rm -v "$PWD:/tests/" "$IMAGE" /tests/.tests.R
