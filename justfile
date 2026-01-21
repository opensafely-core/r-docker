set dotenv-load := true

export UBUNTU_PRO_TOKEN_FILE := env_var_or_default('UBUNTU_PRO_TOKEN_FILE', justfile_directory() + "/.secrets/ubuntu_pro_token")
#enable modern docker build features
export DOCKER_BUILDKIT := "1"
export COMPOSE_DOCKER_CLI_BUILD := "1"


ensure-pro-token:
  #!/bin/bash
  set -euo pipefail
  token_file="{{ UBUNTU_PRO_TOKEN_FILE }}"
  if test -z "${UBUNTU_PRO_TOKEN:-}"; then
    echo "UBUNTU_PRO_TOKEN is required to create $token_file" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$token_file")"
  umask 077
  printf '%s' "$UBUNTU_PRO_TOKEN" > "$token_file"

# build the R image locally
build version: ensure-pro-token
    #!/usr/bin/env bash
    set -euo pipefail

    source {{ version }}/env

    # set build args for prod builds
    export BUILD_DATE=$(date -u +'%y-%m-%dT%H:%M:%SZ')
    export GITREF=$(git rev-parse --short HEAD)

    # build the thing
    docker compose --env-file {{ version }}/env build --pull r

    if [ "{{ version }}" = "v1" ]; then
      # update renv.lock
      cp ${MAJOR_VERSION}/renv.lock ${MAJOR_VERSION}/renv.lock.bak
      # cannot use docker compose run as it mangles the output
      docker run --platform linux/amd64 --rm r:{{ version }} cat /renv/renv.lock > ${MAJOR_VERSION}/renv.lock
    elif [ "{{ version }}" = "v2" ]; then
      # update pkg.lock
      cp ${MAJOR_VERSION}/pkg.lock ${MAJOR_VERSION}/pkg.lock.bak
      # cannot use docker compose run as it mangles the output
      docker run --platform linux/amd64 --rm r:{{ version }} cat /pkg.lock > ${MAJOR_VERSION}/pkg.lock
    fi

    # render the packages.md file
    {{ just_executable() }} render {{ version }}

# render the version/packages.md file
render version:
    docker run --platform linux/amd64 --env-file {{ version }}/env --entrypoint bash --rm -v "/$PWD:/out" -v "$PWD/scripts:/out/scripts" r:{{ version }} "/out/scripts/render.sh"
    
# build and add a package and its dependencies to the image
add-package-v1 package repos="NULL":
    bash v1/scripts/add-package.sh {{ package }} {{ repos }}

# r image containing rstudio-server
build-rstudio version: ensure-pro-token
    docker compose --env-file {{ version }}/env build --pull rstudio

# test the locally built image
test version: _env
    #!/usr/bin/env bash
    source {{ version }}/env
    bash tests/test.sh {{ version }}

# test rstudio-server launches
test-rstudio version: _env
    bash tests/test-rstudio.sh {{ version }}

_env:
    #!/bin/bash
    test -f .env && exit
    echo "HOSTUID=$(id -u)" > .env
    echo "HOSTPLATFORM=$(docker info -f '{{{{ lower .ClientInfo.Os }}')" >> .env

# lint source code
lint version:
    docker pull hadolint/hadolint
    docker run --rm -i hadolint/hadolint < {{ version }}/Dockerfile

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

check:
    uvx --python 3.13 toml-validator v2/packages.toml
