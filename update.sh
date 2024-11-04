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
    install.packages(c('renv', 'pak'), destdir = '/cache', repos = c(CRAN = \"$REPOS\")); \
    pak::add_repos(CRAN = 'RSPM@2024-10-30'); \
    options(renv.config.pak.enabled = TRUE); \
    pkgs <- read.csv('packages.csv')\$Package; \
    pkgs <- pkgs[! pkgs %in% c('renv', 'dummies', 'maptools', 'mnlogit', 'rgdal', 'rgeos')]; \
    renv::install(pkgs, destdir = '/cache'); \
    webshot::install_phantomjs(); \
    renv::install('sjPlot', destdir = '/cache'); \
    # TODO: should I add sf and terra?? \
    renv::snapshot(type = 'all')"
fi
