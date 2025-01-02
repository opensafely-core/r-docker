#!/usr/bin/env bash
set -eu
MAJOR_VERSION=${1}

if [ "${MAJOR_VERSION}" = "v1" ]; then
  # Test all R packages can be loaded
  python3 -c "import json; print('\n'.join(json.load(open(\"./$MAJOR_VERSION/renv.lock\"))['Packages']))" | xargs -I {} echo "if (!library({}, warn.conflicts = FALSE, logical.return = TRUE)) {stop(\"Package {} failed to load, please investigate\")}" > .tests.R
  docker run --platform linux/amd64 --rm -v "$PWD:/tests/" r:${MAJOR_VERSION} /tests/.tests.R
elif [ "${MAJOR_VERSION}" = "v2" ]; then
  # Test all R packages can be attached then detached
  docker run --platform linux/amd64 --env-file ${MAJOR_VERSION}/env --rm -v "${PWD}:/tests" r:"${MAJOR_VERSION}" /tests/tests/test-loading-packages.R
fi

# Check that a basic Rcpp call runs successfully
docker compose --env-file ${MAJOR_VERSION}/env run --rm r -e "if (is.numeric(Rcpp::evalCpp('2 + 2'))) {print('Rcpp test passed')}"

# Check number of packages
docker compose --env-file ${MAJOR_VERSION}/env run --rm r -e "print(paste('Total number of R packages:', nrow(installed.packages())))"

# Check capabilities of arrow package
docker compose --env-file ${MAJOR_VERSION}/env run --rm r -e "arrow::arrow_info()"

# Test loading the 14 base packages
docker run --platform linux/amd64 --env-file ${MAJOR_VERSION}/env --rm -v "${PWD}:/tests" r:"${MAJOR_VERSION}" /tests/tests/test-loading-base.R
