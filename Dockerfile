FROM ubuntu:bionic

RUN apt-get update --fix-missing

# Allows us to use add-apt-repository (below)
RUN apt-get install -y software-properties-common

# R install per https://cran.r-project.org/bin/linux/ubuntu/README.html
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release --codename --short)-cran40/"

# Required for non-interactive R install
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London
RUN apt-get install -y tzdata

# Requirements for most things in CRAN, taken from
# https://packagemanager.rstudio.com/client/#/repos/2/overview

RUN apt-get install -y bowtie2 bwidget cargo cmake coinor-libclp-dev dcraw default-jdk gdal-bin git haveged imagej imagemagick jags libapparmor-dev libatk1.0-dev libcairo2-dev libfftw3-dev libfontconfig1-dev libfreetype6-dev libgdal-dev libgeos-dev libgl1-mesa-dev libglib2.0-dev libglpk-dev libglu1-mesa-dev libgmp3-dev libgpgme11-dev libgsl0-dev libgtk2.0-dev libhdf5-dev libhiredis-dev libicu-dev libimage-exiftool-perl libjpeg-dev libjq-dev libleptonica-dev libmagick++-dev libmpfr-dev libmysqlclient-dev libnetcdf-dev libopenmpi-dev libpango1.0-dev libpng-dev libpoppler-cpp-dev libpq-dev libproj-dev libprotobuf-dev libquantlib0-dev librdf0-dev librsvg2-dev libsasl2-dev libsecret-1-dev libsndfile1-dev libsodium-dev libssh2-1-dev libssl-dev libtesseract-dev libtiff-dev libudunits2-dev libv8-dev libwebp-dev libxft-dev libxml2-dev libxslt-dev libzmq3-dev make ocl-icd-opencl-dev pari-gp perl protobuf-compiler python python3 rustc saga saint swftools tcl texlive tk tk-dev tk-table unixodbc-dev zlib1g-dev libraptor2-dev librasqal3-dev libcurl4-gnutls-dev

# Don't install recommended packages; we want to handle all of that ourselves
RUN apt install -y r-base-dev --no-install-recommends


RUN R CMD javareconf


# Now we can install packages
RUN R -e 'install.packages("renv")'
RUN R -e 'renv::consent(provided = TRUE)'
RUN R -e 'renv::init()'

# The 'knitr' package is required to parse dependencies within multi-mode files
RUN R -e 'install.packages("knitr")'

# These have been requested by OS users in https://github.com/opensafely/cohort-extractor/issues/227
RUN R -e 'renv::install("DBI")'
RUN R -e 'renv::install("GGally")'
RUN R -e 'renv::install("Hmisc")'
RUN R -e 'renv::install("NHPoisson")'
RUN R -e 'renv::install("Rcpp")'
RUN R -e 'renv::install("survival")'
RUN R -e 'renv::install("binom")'
RUN R -e 'renv::install("brms")'
RUN R -e 'renv::install("cowplot")'
RUN R -e 'renv::install("data.table")'
RUN R -e 'renv::install("deSolve")'
RUN R -e 'renv::install("doParallel")'
RUN R -e 'renv::install("dplyr")'
RUN R -e 'renv::install("dtplyr")'
RUN R -e 'renv::install("foreach")'
RUN R -e 'renv::install("furrr")'
RUN R -e 'renv::install("ggdist")'
RUN R -e 'renv::install("here")'
RUN R -e 'renv::install("janitor")'
RUN R -e 'renv::install("lme4")'
RUN R -e 'renv::install("lubridate")'
RUN R -e 'renv::install("magrittr")'
RUN R -e 'renv::install("maptools")'
RUN R -e 'renv::install("matrixStats")'
RUN R -e 'renv::install("mgcv")'
RUN R -e 'renv::install("mice")'
RUN R -e 'renv::install("mvtnorm")'
RUN R -e 'renv::install("naniar")'
RUN R -e 'renv::install("nlme")'
RUN R -e 'renv::install("parallel")'
RUN R -e 'renv::install("plotrix")'
RUN R -e 'renv::install("relsurv")'
RUN R -e 'renv::install("rgdal")'
RUN R -e 'renv::install("rgeos")'
RUN R -e 'renv::install("sandwich")'
RUN R -e 'renv::install("sf")'
RUN R -e 'renv::install("stats")'
RUN R -e 'renv::install("stringr")'
RUN R -e 'renv::install("tictoc")'
RUN R -e 'renv::install("tidyverse")'
RUN R -e 'renv::install("zoo")'
RUN R -e 'renv::install("pacman")'

WORKDIR /workspace

RUN R -e 'renv::snapshot(type = "all")'
RUN R -e 'write.csv(installed.packages()[, c("Package","Version")], row.names=FALSE, file="available_packages.csv")'

ENTRYPOINT ["/usr/bin/Rscript"]
