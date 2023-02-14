#!/bin/bash
set -eux
test -n "$1" || { echo "You must specify 'r' or 'apt' for package type"; exit 1; }
test -n "$2" || { echo "You must specify a package name"; exit 1; }
TYPE=$1
PACKAGE=$2
REPO=${3:-}
IMAGE=${IMAGE:-ghcr.io/opensafely-core/r}
# docker tags need to be lowercase
NAME=$(echo "$PACKAGE" | tr '[:upper:]' '[:lower:]')
INSTALL_ARGS="Ncpus=8"
BUILD_DATE="$(date +'%y-%m-%dT%H:%M:%S.%3NZ')"
REVISION="$(git rev-parse --short HEAD)"

trap 'docker container rm $NAME || true' EXIT

docker tag "$IMAGE" r-backup
# build
if test "$TYPE" == "r"; then
    test -n "$REPO" && INSTALL_ARGS=$"$INSTALL_ARGS, repos='$REPO'"
    docker run --name "$NAME" "$IMAGE" -e "install.packages('$PACKAGE', $INSTALL_ARGS)"
else
    docker run --name "$NAME" --entrypoint bash "$IMAGE" -c "apt-get install -y $PACKAGE"
fi
docker commit --change "CMD []" --change 'ENTRYPOINT ["/usr/bin/Rscript"]' --change "LABEL org.opencontainers.image.created=$BUILD_DATE org.opencontainers.image.revision=$REVISION" "$NAME" "r-$NAME" 

if test "$TYPE" == "r"; then
    docker run "r-$NAME" -e "library('$PACKAGE')"
    ./test.sh "r-$NAME"
    if test -n "$REPO"; then
        echo "$PACKAGE  # repo: $REPO" >> packages.txt
    else
        echo "$PACKAGE" >> packages.txt
    fi

else
    echo "$PACKAGE" >> system-packages.txt
fi

docker tag "r-$NAME" "$IMAGE"
docker run -e LC_ALL=C.UTF-8 "$IMAGE" -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file="/dev/stdout")' 2>/dev/null > packages.csv

set +x
echo "Run this to push:"
echo "docker push $IMAGE"
