#!/usr/bin/env bash
set -euo pipefail

# set build args for prod builds
export BUILD_DATE=$(date -u +'%y-%m-%dT%H:%M:%SZ')
export GITREF=$(git rev-parse --short HEAD)
export CRAN_DATE=2024-10-30
export REPOS=https://p3m.dev/cran/__linux__/noble/$CRAN_DATE
if [ test -n "$1" ]; then
  export UPDATE=false
elif [ "$1" = "update" ]; then
  export UPDATE=true
else 
  echo "Please specify `just build` as `just build` or `just build update`"
  exit 1
fi

# build the thing
docker-compose build --pull r
