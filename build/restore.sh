#!/usr/bin/env bash
set -euo pipefail

if [ "$UPDATE" = "false" ]; then
  Rscript /root/restore.R
fi
