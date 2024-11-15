#!/usr/bin/env bash
set -eu
MAJOR_VERSION=${1}

# Test all R packages can be attached then detached
python3 -c "import json; print('\n'.join(json.load(open(\"./$MAJOR_VERSION/renv.lock\"))['Packages']))" | xargs -I {} echo "if (\"{}\" != 'pak') {suppressPackageStartupMessages(library({}, warn.conflicts = FALSE)); suppressWarnings(detach(\"package:{}\", force = TRUE, unload = TRUE))}" > .tests.R
docker run --platform linux/amd64 --env-file ${MAJOR_VERSION}/env --rm -v "${PWD}:/tests" r:"${MAJOR_VERSION}" -q -e "source('/tests/.tests.R', echo = TRUE)"

# Check that a basic Rcpp call runs successfully
docker compose --env-file ${MAJOR_VERSION}/env run --rm r -q -e "Rcpp::evalCpp('2 + 2')"

# Check number of packages
docker compose --env-file ${MAJOR_VERSION}/env run --rm r -q -e "nrow(installed.packages())"
