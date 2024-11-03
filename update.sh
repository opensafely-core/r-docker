#!/usr/bin/env bash
set -euo pipefail

echo "here 2 $UPDATE"
echo "here 2 $REPOS"
echo "here 2 \"$REPOS\""

if [ "$UPDATE" = "true" ]; then
  R -e 'install.packages(c("renv", "pak"), repos = \"$REPOS\", destdir="/cache"); \
    options(renv.config.pak.enabled = TRUE); \
    pkgs <- read.csv("packages.csv")$Package; \
    pkgs <- pkgs[pkgs != "renv"]; \
    renv::install(pkgs, repos = \"$REPOS\", destdir="/cache"); \
    webshot::install_phantomjs(); \
    renv::install("sjPlot", repos = \"$REPOS\", destdir="/cache"); \
    renv::snapshot(type=\"all\")'
fi
