set dotenv-load := true

#enable modern docker build features
export DOCKER_BUILDKIT := "1"
export COMPOSE_DOCKER_CLI_BUILD := "1"

# build the R image locally
build version *update="":
    #!/usr/bin/env bash
    set -eo pipefail

    # set build args for prod builds
    export BUILD_DATE=$(date -u +'%y-%m-%dT%H:%M:%SZ')
    export GITREF=$(git rev-parse --short HEAD)
    export CRAN_DATE=2024-11-03
    export REPOS=https://p3m.dev/cran/__linux__/noble/$CRAN_DATE

    if [ -z "{{ update }}" ]; then
      export UPDATE=false
    elif [ "{{ update }}" = "update" ]; then
      export UPDATE=true
    else
      echo "Please specify -just build- as either -just build- or -just build update-"
      exit 1
    fi

    # build the thing
    docker compose --env-file {{ version }}/env build --pull r

    # update renv.lock
    cp renv.lock renv.lock.bak
    # cannot use docker-compose run as it mangles the output
    docker run --platform linux/amd64 --rm r:{{ version }} cat /renv/renv.lock > renv.lock

    # update packages.csv for backwards compat with current docs
    docker compose --env-file {{ version }}/env run --platform linux/amd64 --rm -v "/$PWD:/out" r -q -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file=paste0("/out/", Sys.getenv(\"MAJOR_VERSION\"), "packages.csv")'

    # render the packages.md file
    docker compose --env-file {{ version }}/env run --rm --platform linux/amd64 -v "/$PWD:/out" r -q -e 'rmarkdown::render("scripts/packages.Rmd", output_dir = paste0("out", Sys.getenv(\"MAJOR_VERSION\")))'


# build and add a package and its dependencies to the image
add-package version package:
    bash scripts/add-package.sh {{ package }}

# r image containing rstudio-server
build-rstudio version:
    #!/usr/bin/env bash
    set -euo pipefail

    # Set RStudio Server .deb filename
    export RSTUDIO_BASE_URL=https://download2.rstudio.org/server/jammy/amd64/
    export RSTUDIO_DEB=rstudio-server-2024.09.0-375-amd64.deb
    docker-compose build --pull rstudio

# test the locally built image
test image="r": (build "version")
    bash tests/test.sh "{{ image }}"

# test the locally built update image
test-update image="r": (build "version" "update")
    bash tests/test.sh "{{ image }}"

# test rstudio-server launches
test-rstudio version: _env
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

publish version:
    #!/usr/bin/env bash
    docker tag r:{{ version }} ghcr.io/opensafely-core/r:{{ version }}
    docker push ghcr.io/opensafely-core/r:{{ version }}
    if [ "{{ version }}" = "v1" ]; then
      docker tag r:{{ version }} ghcr.io/opensafely-core/r:latest
      docker push ghcr.io/opensafely-core/r:latest
    fi

publish-rstudio version:
    docker tag rstudio:{{ version }} ghcr.io/opensafely-core/rstudio:{{ version }}
    docker push ghcr.io/opensafely-core/rstudio:{{ version }}
    if [ "{{ version }}" = "v1" ]; then
      docker tag rstudio:{{ version }} ghcr.io/opensafely-core/rstudio:latest
      docker push ghcr.io/opensafely-core/rstudio:latest
    fi
