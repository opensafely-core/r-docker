set dotenv-load := true

#enable modern docker build features
export DOCKER_BUILDKIT := "1"
export COMPOSE_DOCKER_CLI_BUILD := "1"

# build the R image locally
build version package="nopackage":
    #!/usr/bin/env bash
    set -euo pipefail

    source {{ version }}/env

    # set build args for prod builds
    export BUILD_DATE=$(date -u +'%y-%m-%dT%H:%M:%SZ')
    export GITREF=$(git rev-parse --short HEAD)

    if [ "{{ version }}" = "v1" ] && [ "${UPDATE}" = "true" ]; then
      echo "Error: UPDATE=true specified with version=v1; UPDATE=true can only be specified with version=v2."
      exit 1
    fi

    if [ "${{ package }}" = "nopackage" ]; then
      export PACKAGE=""
    else
      export PACKAGE={{ package }}
    fi    
    
    # build the thing
    docker-compose --env-file {{ version }}/env build --pull r

    # update renv.lock
    cp ${MAJOR_VERSION}/renv.lock ${MAJOR_VERSION}/renv.lock.bak
    # cannot use docker-compose run as it mangles the output
    docker run --platform linux/amd64 --rm r:{{ version }} cat /renv/renv.lock > ${MAJOR_VERSION}/renv.lock

    # update packages.csv for backwards compat with current docs
    docker compose --env-file {{ version }}/env run --rm -v "/$PWD:/out" r -e "write.csv(installed.packages()[, c('Package','Version')], row.names=FALSE, file=paste0('/out/', \"$MAJOR_VERSION\", '/packages.csv'))"

    # render the packages.md file
    {{ just_executable() }} render {{ version }}

    # Run tests after build
    {{ just_executable() }} test {{ version }}

# render the version/packages.md file
render version:
    docker run --platform linux/amd64 --env-file {{ version }}/env --entrypoint bash --rm -v "/$PWD:/out" -v "$PWD/scripts:/out/scripts" r:{{ version }} "/out/scripts/render.sh"
    
# build and add a package and its dependencies to the image
add-package version package:
    #!/usr/bin/env bash
    if [ "{{version}}" != "v1" ]; then
      echo "The version argument to add-package must be v1"
      exit 1
    fi
    bash ./add-package.sh {{ version }} {{ package }}

# r image containing rstudio-server
build-rstudio version:
    docker-compose --env-file {{ version }}/env build --pull rstudio

# test the locally built image
test version:
    #!/usr/bin/env bash
    source {{ version }}/env
    bash tests/test.sh {{ version }}

# test rstudio-server launches
test-rstudio version: _env
    bash ./test-rstudio.sh {{ version }}

_env:
    #!/bin/bash
    test -f .env && exit
    echo "HOSTUID=$(id -u)" > .env
    echo "HOSTPLATFORM=$(docker info -f '{{{{ lower .ClientInfo.Os }}')" >> .env

# lint source code
lint:
    docker pull hadolint/hadolint
    docker run --rm -i hadolint/hadolint < Dockerfile

publish version:
    #!/usr/bin/env bash
    docker tag r:{{ version }} ghcr.io/opensafely-core/r:{{ version }}
    docker push ghcr.io/opensafely-core/r:{{ version }}
    if [ "{{ version }}" = "v1" ]; then
      docker tag r:{{ version }} ghcr.io/opensafely-core/r:latest
      docker push ghcr.io/opensafely-core/r:latest
    fi

publish-rstudio version:
    #!/usr/bin/env bash
    docker tag rstudio:{{ version }} ghcr.io/opensafely-core/rstudio:{{ version }}
    docker push ghcr.io/opensafely-core/rstudio:{{ version }}
    if [ "{{ version }}" = "v1" ]; then
      docker tag rstudio:{{ version }} ghcr.io/opensafely-core/rstudio:latest
      docker push ghcr.io/opensafely-core/rstudio:latest
    fi
