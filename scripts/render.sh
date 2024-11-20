#!/usr/bin/env bash
set -euo pipefail

echo "BASE=$BASE" >> /usr/lib/R/etc/Renviron.site
echo "MAJOR_VERSION=$MAJOR_VERSION" >> /usr/lib/R/etc/Renviron.site
R -e "rmarkdown::render('/out/scripts/packages.Rmd', output_dir = paste0('/out/', \"$MAJOR_VERSION\"))"
