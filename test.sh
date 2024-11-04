#!/usr/bin/env bash
set -eu
IMAGE=${1:-ghcr.io/opensafely-core/r}
python3 -c 'import json; print("\n".join(json.load(open("renv.lock"))["Packages"]))' | xargs -I {} echo "library({}, warn.conflicts = FALSE); detach(package:{})" > .tests.R
docker run --platform linux/amd64 --rm -v "$PWD:/tests/" "$IMAGE" -e "source('/tests/.tests.R', echo = TRUE)"
