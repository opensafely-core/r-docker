#!/bin/bash
set -euo pipefail
test -n "$1" || { echo "You must specify a package name. If you want a specific version, append @VERSION"; exit 1; }

cp renv.lock renv.lock.bak
export PACKAGE=$1
IMAGE=${IMAGE:-r}
echo "Attempting to build and install $PACKAGE"

if ! docker-compose build add-package; then
    echo "Builing $PACKAGE failed."
    echo "You may need to add build dependencies (e.g. -dev packages) to build-dependencies.txt"
    exit 1
fi

# update renv.lock 
cp renv.lock renv.lock.bak
# cannot use docker-compose run as it mangles the output
docker run --rm "r-$PACKAGE" cat /renv/renv.lock > renv.lock

echo "$PACKAGE and its dependencies built and cached, renv.lock updated." 
echo "Rebuilding R image with new renv.lock file." 

if ! just build; then
    echo "Building the image with the new package failed"
    exit 1
fi 

just test "$IMAGE"

# update packages.csv for backwards compat with current docs
docker run "$IMAGE" -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file="/dev/stdout")' 2>/dev/null | sort > packages.csv
