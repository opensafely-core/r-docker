#!/usr/bin/env bash
set -eu
MAJOR_VERSION=${1}

# Test all R packages can be attached then detached
echo "$MAJOR_VERSION"
python3 -c "import json; print('\n'.join(json.load(open(\"${MAJOR_VERSION}/renv.lock\"))['Packages']))" | xargs -I {} echo "library({}, warn.conflicts = FALSE); suppressWarnings(detach(\"package:{}\", force = TRUE))" > /tests/.tests.R
docker compose --env-file ${MAJOR_VERSION}/env run --platform linux/amd64 --rm -v "${PWD}/tests:/tests/" r:"${MAJOR_VERSION}" -e "source('/tests/.tests.R', echo = TRUE)"

# Check that a basic Rcpp call runs successfully
docker compose run --platform linux/amd64 --rm r:"$MAJOR_VERSION" -e "Rcpp::evalCpp('2 + 2')"
