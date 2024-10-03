#!/bin/bash
set -eu
OSTYPEFIRSTFIVE=$(echo "$OSTYPE" | cut -c1-5)
if [[ "$OSTYPEFIRSTFIVE" == "linux" ]]; then
  PLATFORM="linux"
else
  PLATFORM="somethingelse"
  echo "success"
fi

docker run --rm --init --label=opensafely --interactive \
    --user=0:0 --volume=$PWD://workspace --platform=linux/amd64 -p=8787:8787 \
    --name=test_rstudio --hostname=test_rstudio \
    --volume=$HOME/.gitconfig:/home/rstudio/local-gitconfig \
    --env=HOSTPLATFORM=$PLATFORM \
    --env=HOSTUID=$(id -u) \
    rstudio
