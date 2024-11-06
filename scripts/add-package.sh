#!/usr/bin/env bash
set -euo pipefail
test -n "$1" || { echo "You must specify a package name. If you want a specific version, append @VERSION"; exit 1; }

export PACKAGE="$1"
IMAGE_TAG="r-$(echo "${PACKAGE%@*}" | tr "[:upper:]" "[:lower:]")"
export IMAGE_TAG
IMAGE=${IMAGE:-r}
echo "Attempting to build and install $PACKAGE"

if ! docker-compose build add-package; then
    echo "Building $PACKAGE failed."
    echo "You may need to add build dependencies (e.g. -dev packages) to build-dependencies.txt"
    echo "Alternatively, you may need to install an older version of $PACKAGE. Please see the Trouble shooting section of the README."
    exit 1
fi

# update renv.lock 
cp renv.lock renv.lock.bak
# cannot use docker-compose run as it mangles the output
docker run --rm "$IMAGE_TAG" cat /renv/renv.lock > renv.lock

echo "$PACKAGE and its dependencies built and cached, renv.lock updated."
echo "Rebuilding R image with new renv.lock file."

if ! just build; then
    echo "Building the image with the new package failed"
    exit 1
fi 

just test "$IMAGE"

# update packages.csv for backwards compat with current docs
docker run --platform linux/amd64 -v "/$PWD:/out" "$IMAGE" -q -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file=paste0("/out/", Sys.getenv(\"MAJOR_VERSION\"), "packages.csv")'
