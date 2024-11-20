#!/usr/bin/env bash
set -eu
MAJOR_VERSION=${1}

if [ "${MAJOR_VERSION}" = "v1" ]; then
  python3 -c "import json; print('\n'.join(json.load(open(\"./$MAJOR_VERSION/renv.lock\"))['Packages']))" | xargs -I {} echo "library({}, warn.conflicts = FALSE)" > .tests.R
  docker run --platform linux/amd64 --rm -v "$PWD:/tests/" r:${MAJOR_VERSION} /tests/.tests.R
elif [ "${MAJOR_VERSION}" = "v2" ]; then
  # Test all R packages can be attached then detached
  python3 -c "import json; print('\n'.join(json.load(open(\"./$MAJOR_VERSION/renv.lock\"))['Packages']))" | xargs -I {} echo "suppressPackageStartupMessages(library({}, warn.conflicts = FALSE)); suppressWarning(detach(\"package:{}\", force = TRUE, unload = TRUE))" > .tests.R
  docker run --platform linux/amd64 --env-file ${MAJOR_VERSION}/env --rm -v "${PWD}:/tests" r:"${MAJOR_VERSION}" -e "source('/tests/.tests.R', echo = TRUE)"
fi

# Check that a basic Rcpp call runs successfully
docker compose --env-file ${MAJOR_VERSION}/env run --rm r -e "Rcpp::evalCpp('2 + 2')"

# Check number of packages
docker compose --env-file ${MAJOR_VERSION}/env run --rm r -e "nrow(installed.packages())"
