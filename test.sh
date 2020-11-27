#!/bin/bash
set -eu
IMAGE=${1:-docker.opensafely.org/r}
tests=$(grep renv::install Dockerfile | sed -e 's/.*renv::install("\(.*\)").*/library("\1", warn.conflicts = FALSE)/')
docker run $IMAGE -e "$tests"
