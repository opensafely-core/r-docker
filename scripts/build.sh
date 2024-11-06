#!/usr/bin/env bash
set -eo pipefail

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
docker compose --env-file $MAJOR_VERSION/env build --pull r

# update renv.lock
cp renv.lock renv.lock.bak
# cannot use docker-compose run as it mangles the output
docker run --platform linux/amd64 --rm r:$MAJOR_VERSION cat /renv/renv.lock > renv.lock

# update packages.csv for backwards compat with current docs
docker compose --env-file $MAJOR_VERSION/env run --platform linux/amd64 --rm -v "/$PWD:/out" r -q -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file="/out/packages.csv")'

# render the packages.md file
docker compose --env-file $MAJOR_VERSION/env run --rm --platform linux/amd64 -v "/$PWD:/out" r -q -e 'rmarkdown::render("scripts/packages.Rmd", output_dir = paste0("out", Sys.getenv(\"MAJOR_VERSION\")))'
