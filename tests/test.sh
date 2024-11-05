#!/usr/bin/env bash
set -eu
IMAGE=${1:-ghcr.io/opensafely-core/r}

# Test all R packages can be attached then detached
python3 -c 'import json; print("\n".join(json.load(open("renv.lock"))["Packages"]))' | xargs -I {} echo "library({}, warn.conflicts = FALSE); suppressWarnings(detach(\"package:{}\", force = TRUE))" > .tests.R
docker run --platform linux/amd64 --rm -v "$PWD:/tests/" "$IMAGE" -e "source('/tests/.tests.R', echo = TRUE)"
