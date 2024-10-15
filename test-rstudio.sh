#!/bin/bash
set -eu

# Detect operating system for `docker run` call
OSTYPEFIRSTFIVE=$(echo "$OSTYPE" | cut -c1-5)
if [[ "$OSTYPEFIRSTFIVE" == "linux" ]]; then
  PLATFORM="linux"
else
  PLATFORM="somethingelse"
fi

trap "docker compose kill > /dev/null 2>&1 || true" EXIT

docker compose up -d --wait rstudio

status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null -L --retry 3 --max-time 10 http://localhost:8787)
if [[ "$status_code" -ne 200 ]] ; then
  echo "200 response not received from http://localhost:8787"
  exit 1
else
  echo "200 response successfully received from http://localhost:8787"
  exit 0
fi
