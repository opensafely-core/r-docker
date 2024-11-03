#!/usr/bin/env bash
set -euo pipefail

if [ "$UPDATE" = "false" ]; then 
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
    install.packages(c('renv', 'pak'), repos = c(CRAN = \"$REPOS\"), destdir = '/cache'); \
    options(renv.config.pak.enabled = FALSE); \
    renv::init(bare = TRUE); \
    renv::restore()"
fi
