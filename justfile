set dotenv-load := true

#enable modern docker build features
export DOCKER_BUILDKIT := "1"
export COMPOSE_DOCKER_CLI_BUILD := "1"

# build the R image locally
build: 
    #!/usr/bin/env bash
    set -euo pipefail


    # set build args for prod builds
    export BUILD_DATE=$(date -u +'%y-%m-%dT%H:%M:%SZ')
    export GITREF=$(git rev-parse --short HEAD)

    # build the thing
    docker-compose build --pull r


# build and add a package and its dependencies to the image
add-package package:
    bash ./add-package.sh {{ package }}

# r image containing rstudio-server
build-rstudio:
    docker-compose build --pull rstudio

# test the locally built image
test image="r": build
    bash ./test.sh "{{ image }}"

# test rstudio-server launches
test-rstudio:
    bash ./test-rstudio.sh

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
