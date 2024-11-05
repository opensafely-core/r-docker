#!/usr/bin/env bash
set -euo pipefail

if [ "$UPDATE" = "true" ]; then
  Rscript /root/update.R
fi
