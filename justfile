set dotenv-load := true

# build the R image locally
build: 
    #!/usr/bin/env bash
    set -euo pipefail

    # enable modern docker build features
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1

    # set build args for prod builds
    export BUILD_DATE=$(date -u +'%y-%m-%dT%H:%M:%SZ')
    export GITREF=$(git rev-parse --short HEAD)

    # build the thing
    docker-compose build --pull r


# build and a package and its dependencies to the image
add-package package:
    ./add-package.sh {{ package }}


# test the locally built image
test image="r": build
    ./test.sh "{{ image }}"


# lint source code
lint:
    docker pull hadolint/hadolint
    docker run --rm -i hadolint/hadolint < Dockerfile
