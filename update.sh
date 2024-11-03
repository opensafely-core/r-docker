#!/usr/bin/env bash
set -euo pipefail

if [ "$UPDATE" = "true" ]; then
  R -e "options(HTTPUserAgent = \
      sprintf(\"R/%s R (%s)\", \
        getRversion(), \
        paste(getRversion(), \
          R.version[\"platform\"], \
          R.version[\"arch\"], \
          R.version[\"os\"] \
        ) \
      ) \
    ); \
    options(repos = c(CRAN = \"$REPOS\")); \
    install.packages(c('renv', 'pak'), destdir = '/cache'); \
    options(renv.config.pak.enabled = FALSE); \
    pkgs <- read.csv('packages.csv')\$Package; \
    pkgs <- pkgs[pkgs != 'renv']; \
    pkgs <- pkgs[pkgs != 'dummies']; \
    renv::install(pkgs, destdir = '/cache'); \
    webshot::install_phantomjs(); \
    renv::install('sjPlot', destdir = '/cache'); \
    renv::snapshot(type = 'all')"
fi
