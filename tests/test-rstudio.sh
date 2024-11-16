#!/bin/bash
set -euo pipefail

MAJOR_VERSION="$1"

trap "docker compose kill > /dev/null 2>&1 || true" EXIT

docker compose --env-file ${MAJOR_VERSION}/env up -d --wait --wait-timeout 30 rstudio

status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null -L --retry 10 --max-time 30 http://localhost:8787)
if [[ "$status_code" -ne 200 ]] ; then
  echo "200 response not received from http://localhost:8787"
  exit 1
else
  echo "200 response successfully received from http://localhost:8787"
  exit 0
fi
