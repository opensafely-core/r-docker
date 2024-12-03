#!/usr/bin/env bash
set -eu
IMAGE=${1:-ghcr.io/opensafely-core/r}
python3 -c 'import json; print("\n".join(json.load(open("renv.lock"))["Packages"]))' | xargs -I {} echo "if (!library({}, warn.conflicts = FALSE, logical.return = TRUE)) {stop(\"Package {} failed to load, please investigate\")}" > .tests.R
docker run --platform linux/amd64 --rm -v "$PWD:/tests/" "$IMAGE" /tests/.tests.R
