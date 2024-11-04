#!/usr/bin/env bash
set -euo pipefail

if [ "$UPDATE" = "true" ]; then
  mv renv.lock renv.lock.bak
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
    install.packages('renv', destdir = '/cache', repos = c(CRAN = \"$REPOS\")); \
    renv::init(bare = TRUE); \
    renv::snapshot(type = 'all'); \
    renv::install('pak', destdir = '/cache', repos = c(CRAN = \"$REPOS\")); \
    pak::repo_add(CRAN = \"RSPM@$CRAN_DATE\"); \
    options(renv.config.pak.enabled = TRUE); \
    pkgs <- read.csv('packages.csv')\$Package; \
    pkgs <- pkgs[! pkgs %in% c('renv', 'dummies', 'maptools', 'mnlogit', 'rgdal', 'rgeos')]; \
    renv::install(pkgs, destdir = '/cache'); \
    webshot::install_phantomjs(); \
    renv::install('sjPlot', destdir = '/cache'); \
    renv::snapshot(type = 'all'); \
    renv::activate(); \
    renv::status()"
  docker run --rm r cat /renv/renv.lock > renv.lock
fi
