#!/usr/bin/env bash
echo "BASE=$BASE" >> /usr/lib/R/etc/Renviron.site
echo "MAJOR_VERSION=$MAJOR_VERSION" >> /usr/lib/R/etc/Renviron.site
R -q -e "print(Sys.getenv('MAJOR_VERSION'))"
R -q -e "rmarkdown::render('/out/scripts/packages.Rmd', output_dir = paste0('/out/', \"$MAJOR_VERSION\"))"
