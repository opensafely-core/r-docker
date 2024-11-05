set dotenv-load := true

#enable modern docker build features
export DOCKER_BUILDKIT := "1"
export COMPOSE_DOCKER_CLI_BUILD := "1"

# build the R image locally
build *update:
    bash ./scripts/build.sh {{ update }}

# build and add a package and its dependencies to the image
add-package package:
    bash ./scripts/add-package.sh {{ package }}

# r image containing rstudio-server
build-rstudio:
    #!/usr/bin/env bash
    set -euo pipefail

    # Set RStudio Server .deb filename
    export RSTUDIO_BASE_URL=https://download2.rstudio.org/server/jammy/amd64/
    export RSTUDIO_DEB=rstudio-server-2024.09.0-375-amd64.deb
    docker-compose build --pull rstudio

# test the locally built image
test image="r": build
    bash tests/test.sh "{{ image }}"

# test the locally built update image
test-update image="r": (build "update")
    bash tests/test.sh "{{ image }}"

# test rstudio-server launches
test-rstudio: _env
    bash tests/test-rstudio.sh

_env:
    #!/bin/bash
    test -f .env && exit
    echo "HOSTUID=$(id -u)" > .env
    echo "HOSTPLATFORM=$(docker info -f '{{{{ lower .ClientInfo.Os }}')" >> .env

# lint source code
lint:
    docker pull hadolint/hadolint
    docker run --rm -i hadolint/hadolint < Dockerfile

publish:
    docker tag r ghcr.io/opensafely-core/r:latest
    docker push ghcr.io/opensafely-core/r:latest

publish-rstudio:
    docker tag rstudio ghcr.io/opensafely-core/rstudio:latest
    docker push ghcr.io/opensafely-core/rstudio:latest
