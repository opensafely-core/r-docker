#!/bin/bash
set -eu

# Detect operating system for `docker run` call
OSTYPEFIRSTFIVE=$(echo "$OSTYPE" | cut -c1-5)
if [[ "$OSTYPEFIRSTFIVE" == "linux" ]]; then
  PLATFORM="linux"
else
  PLATFORM="somethingelse"
fi

docker run \
    --rm \
    --init \
    --label=opensafely \
    --interactive \
    --user=0:0 --volume="/${PWD}://workspace" \
    --platform=linux/amd64 \
    -p=8787:8787 \
    --name=test_rstudio \
    --hostname=test_rstudio \
    --volume="/${HOME}/.gitconfig:/home/rstudio/local-gitconfig" \
    --env=HOSTPLATFORM=${PLATFORM} \
    --env=HOSTUID=$(id -u) \
    rstudio &

sleep 5

status_code=$(curl --write-out %{http_code} --silent --output /dev/null -L http://localhost:8787)
if [[ "$status_code" -ne 200 ]] ; then
  echo "Response not received from http://localhost:8787"
  docker stop test_rstudio || true
  exit 1
else
  echo "200 response successfully received from http://localhost:8787"
  docker stop test_rstudio > /dev/null 2>&1
  exit 0
fi
