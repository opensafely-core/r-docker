#!/bin/bash
set -eux
PACKAGE=$1
IMAGE=${2:-docker.opensafely.org/r}

docker tag $IMAGE r-backup
# build
docker run --name $PACKAGE docker.opensafely.org/r -e "install.packages('$PACKAGE')"
docker commit --change "CMD []" $PACKAGE r-$PACKAGE
docker rm $PACKAGE
docker run r-$PACKAGE -e "library('$PACKAGE')"
./test.sh r-$PACKAGE
docker tag r-$PACKAGE $IMAGE

set +x
echo "Run this to push:"
echo "docker push $IMAGE"



