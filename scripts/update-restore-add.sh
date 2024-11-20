#!/usr/bin/env bash
# If stub of PPPM URL in renv.lock do a restore (and possibly add a package)
if grep -q https://packagemanager.posit.co/cran/ /renv/renv.lock; then
  Rscript /root/restore.R
else
# If stub of PPPM URL not in renv.lock do an update
  Rscript /root/update.R
fi
