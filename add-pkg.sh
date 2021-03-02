#!/bin/bash
set -eux
PACKAGE=$1
TYPE=${2:-r}
IMAGE=${IMAGE:-ghcr.io/opensafely-core/r}
# docker tags need to be lowercase
NAME=$(echo "$PACKAGE" | tr '[:upper:]' '[:lower:]')

trap 'docker container rm $NAME || true' EXIT

docker tag "$IMAGE" r-backup
# build
if test "$TYPE" == "r"; then
    docker run --name "$NAME" "$IMAGE" -e "install.packages('$PACKAGE')"
else
    docker run --name "$NAME" --entrypoint bash "$IMAGE" -c "apt-get install -y $PACKAGE"
fi
docker commit --change "CMD []" --change 'ENTRYPOINT ["/usr/bin/Rscript"]' "$NAME" "r-$NAME"

if test "$TYPE" == "r"; then
    docker run "r-$NAME" -e "library('$PACKAGE')"
    ./test.sh "r-$NAME"
    echo "$PACKAGE" >> packages.txt
fi

docker tag "r-$NAME" "$IMAGE"
docker run -v "$PWD:/out" "$IMAGE" -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file="/out/packages.csv")'

set +x
echo "Run this to push:"
echo "docker push $IMAGE"



