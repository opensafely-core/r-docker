#!/usr/bin/env bash

# Extract the date from the renv.lock file
RENVCRANDATE=$(grep https://packagemanager.posit.co/cran/ /renv/renv.lock | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')

# If stub of PPPM URL in renv.lock and CRAN_DATE matches that in renv.lock do a restore
# (and possibly add a package)
if grep -q https://packagemanager.posit.co/cran/ /renv/renv.lock && [ "$RENVCRANDATE" = "${CRAN_DATE}" ]; then
  echo "Restore"
  Rscript /root/restore.R
else
# If stub of PPPM URL not in renv.lock do an update
  echo "Update"
  Rscript /root/update.R
fi
