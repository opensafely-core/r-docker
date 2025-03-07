#!/usr/bin/env bash
set -eu
MAJOR_VERSION=${1}

trap "rm -rf .tests.R ./lib || true" EXIT

run_test() {
  MAJOR_VERSION=$1
  TEST_SCRIPT=$2
  docker run --platform linux/amd64 --env-file "${MAJOR_VERSION}"/env --rm -v "${PWD}:/workspace" r:"${MAJOR_VERSION}" "${TEST_SCRIPT}"
}

if [ "${MAJOR_VERSION}" = "v1" ]; then
  # Test all R packages can be loaded
  python3 -c "import json; print('\n'.join(json.load(open(\"./$MAJOR_VERSION/renv.lock\"))['Packages']))" | xargs -I {} echo "if (!library({}, warn.conflicts = FALSE, logical.return = TRUE)) {stop(\"Package {} failed to load, please investigate\")}" > .tests.R
  run_test "${MAJOR_VERSION}" ./tests/.tests.R
elif [ "${MAJOR_VERSION}" = "v2" ]; then
  # Test all R packages can be attached then detached
  run_test "${MAJOR_VERSION}" ./tests/test-loading-packages.R
fi

# Check that a basic Rcpp call runs successfully
run_test "${MAJOR_VERSION}" ./tests/test-rcpp.R

# Check number of packages
run_test "${MAJOR_VERSION}" ./tests/test-number-packages.R

# Check capabilities of arrow package
run_test "${MAJOR_VERSION}" ./tests/test-arrow.R

# Test loading the 14 base packages
run_test "${MAJOR_VERSION}" ./tests/test-loading-base.R

# Test user installed paackages on v2
if [ "${MAJOR_VERSION}" = "v2" ]; then
  # Test installing and loading in same R session
  run_test "${MAJOR_VERSION}" ./tests/unlink-lib.R
  run_test "${MAJOR_VERSION}" ./tests/test-user-install-package.R

  # Test installing and loafding in different R sessions
  run_test "${MAJOR_VERSION}" ./tests/unlink-lib.R
  run_test "${MAJOR_VERSION}" ./tests/test-preinstalled-user-package-step-1.R
  run_test "${MAJOR_VERSION}" ./tests/test-preinstalled-user-package-step-2.R
fi
