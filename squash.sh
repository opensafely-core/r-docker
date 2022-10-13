#!/bin/bash
# 
# This will attempt to squash the current image into a single layer
set -euo pipefail
IMAGE=ghcr.io/opensafely-core/r
TAG=squashed

docker pull $IMAGE
docker run -dit --entrypoint bash --name r-squash $IMAGE
trap "docker kill r-squash" EXIT

# export and import the image, changing the CMD, ENTRYPOINT, and WORKDIR back
# to their original values (as the run line above alters them).
docker export r-squash | docker import - --change 'CMD []' --change 'ENTRYPOINT ["/usr/bin/Rscript"]' --change 'WORKDIR /workspace' "$IMAGE:$TAG"

./test.sh "$IMAGE:$TAG"
