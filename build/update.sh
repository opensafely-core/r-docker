#!/usr/bin/env bash
set -euo pipefail

if [ "$UPDATE" = "true" ]; then
  mv renv.lock renv.lock.bak
  Rscript /root/update.R
fi
