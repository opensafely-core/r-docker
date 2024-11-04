#!/usr/bin/env bash
set -euo pipefail

# set build args for prod builds
export BUILD_DATE=$(date -u +'%y-%m-%dT%H:%M:%SZ')
export GITREF=$(git rev-parse --short HEAD)
export CRAN_DATE=2024-11-03
export REPOS=https://p3m.dev/cran/__linux__/noble/$CRAN_DATE

if [ -z "$1" ]; then
  export UPDATE=false
elif [ "$1" = "update" ]; then
  export UPDATE=true
else
  echo "Please specify -just build- as either -just build- or -just build update-"
  exit 1
fi

# build the thing
docker-compose build --pull r

# update renv.lock 
cp renv.lock renv.lock.bak
# cannot use docker-compose run as it mangles the output
docker run --rm r cat /renv/renv.lock > renv.lock

# update packages.csv for backwards compat with current docs
docker run r 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file="/dev/stdout")' 2>/dev/null > packages.csv
