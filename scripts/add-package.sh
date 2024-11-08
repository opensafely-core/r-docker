#!/usr/bin/env bash
set -euo pipefail
export MAJOR_VERSION="$1"
test -n "$2" || { echo "You must specify a package name. If you want a specific version, append @VERSION"; exit 1; }

export PACKAGE="$2"
IMAGE_TAG="r-$(echo "${PACKAGE%@*}" | tr "[:upper:]" "[:lower:]")"
export IMAGE_TAG
IMAGE=${IMAGE:-r}
echo "Attempting to build and install $PACKAGE"

if ! docker compose --env-file ${MAJOR_VERSION}/env build add-package; then
    if [ "${MAJOR_VERSION" = "v1" ]; then
      echo "Building $PACKAGE failed."
      echo "You may need to add build dependencies (e.g. -dev packages) to ${MAJOR_VERSION}/build-dependencies.txt"
      echo "Alternatively, you may need to install an older version of $PACKAGE. Please see the Trouble shooting section of the README."
    elif [ "${MAJOR_VERSION" = "v2" ]; then
      echo "Adding $PACKAGE failed."
      echo "Check that the package was on CRAN on ${CRAN_DATE}."
      echo "If it was not it cannot be added."
    fi
    exit 1
fi

# update renv.lock
cp ${MAJOR_VERSION}/renv.lock ${MAJOR_VERSION}/renv.lock.bak
# cannot use docker-compose run as it mangles the output
docker run --rm "$IMAGE_TAG" cat /renv/renv.lock > ${MAJOR_VERSION}/renv.lock

echo "$PACKAGE and its dependencies built and cached, ${MAJOR_VERSION}/renv.lock updated."
echo "Rebuilding R image with new renv.lock file."

if ! just build "$MAJOR_VERSION"; then
    echo "Building the image with the new package failed"
    exit 1
fi

just test "$IMAGE"

# update packages.csv for backwards compat with current docs
docker compose --env-file ${MAJOR_VERSION}/env run --platform linux/amd64 -v "/$PWD:/out" "$IMAGE" -q -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file=paste0("/out/", Sys.getenv(\"MAJOR_VERSION\"), "packages.csv")'
