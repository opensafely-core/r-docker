#!/bin/bash
set -eux
PACKAGE=$1
IMAGE=${2:-ghcr.io/opensafely-core/r}
# docker tags need to be lowercase
NAME=$(echo $PACKAGE | tr A-Z a-z)

docker tag $IMAGE r-backup
# build
docker run --name $NAME $IMAGE -e "install.packages('$PACKAGE')"
docker commit --change "CMD []" $NAME r-$NAME
docker rm $NAME
docker run r-$NAME -e "library('$PACKAGE')"
./test.sh r-$NAME
docker tag r-$NAME $IMAGE
echo $PACKAGE >> packages.txt
docker run -v $PWD:/out $IMAGE -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file="/out/packages.csv")'

set +x
echo "Run this to push:"
echo "docker push $IMAGE"



