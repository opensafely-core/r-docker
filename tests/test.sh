#!/usr/bin/env bash
set -eu
MAJOR_VERSION=${1}

# Test all R packages can be attached then detached
python3 -c "import json; print('\n'.join(json.load(open(\"./$MAJOR_VERSION/renv.lock\"))['Packages']))" | xargs -I {} echo "library({}, warn.conflicts = FALSE); suppressWarnings(detach(\"package:{}\", force = TRUE))" > .tests.R
docker run --platform linux/amd64 --env-file ${MAJOR_VERSION}/env --rm -v "${PWD}:/tests" r:"${MAJOR_VERSION}" -e "source('/tests/.tests.R', echo = TRUE)"

# Check that a basic Rcpp call runs successfully
docker compose --env-file ${MAJOR_VERSION}/env run --rm r -e "Rcpp::evalCpp('2 + 2')"
