#!/usr/bin/env bash
set -euo pipefail

if [ "$UPDATE" = "false" ]; then 
  R -e 'install.packages(c("renv", "pak"), repos = \"$REPOS\", destdir="/cache"); \
    options(renv.config.pak.enabled = TRUE); \
    renv::init(bare = TRUE); \
    renv::restore()'
fi
