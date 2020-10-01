FROM docker.opensafely.org/base-docker

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


# The knitr packages is required to parse dependencies within multi-mode files
RUN R -e 'install.packages("knitr")'

# These have been requested by OS users in https://github.com/opensafely/cohort-extractor/issues/227
RUN R -e 'install.packages("DBI")'
RUN R -e 'install.packages("GGally")'
RUN R -e 'install.packages("Hmisc")'
RUN R -e 'install.packages("NHPoisson")'
RUN R -e 'install.packages("Rcpp")'
RUN R -e 'install.packages("survival")'
RUN R -e 'install.packages("binom")'
RUN R -e 'install.packages("brms")'
RUN R -e 'install.packages("cowplot")'
RUN R -e 'install.packages("data.table")'
RUN R -e 'install.packages("deSolve")'
RUN R -e 'install.packages("doParallel")'
RUN R -e 'install.packages("dplyr")'
RUN R -e 'install.packages("dtplyr")'
RUN R -e 'install.packages("foreach")'
RUN R -e 'install.packages("furrr")'
RUN R -e 'install.packages("ggdist")'
RUN R -e 'install.packages("here")'
RUN R -e 'install.packages("janitor")'
RUN R -e 'install.packages("lme4")'
RUN R -e 'install.packages("lubridate")'
RUN R -e 'install.packages("magrittr")'
RUN R -e 'install.packages("maptools")'
RUN R -e 'install.packages("matrixStats")'
RUN R -e 'install.packages("mgcv")'
RUN R -e 'install.packages("mice")'
RUN R -e 'install.packages("mvtnorm")'
RUN R -e 'install.packages("naniar")'
RUN R -e 'install.packages("nlme")'
RUN R -e 'install.packages("pacman")'
RUN R -e 'install.packages("parallel")'
RUN R -e 'install.packages("plotrix")'
RUN R -e 'install.packages("relsurv")'
RUN R -e 'install.packages("rgdal")'
RUN R -e 'install.packages("rgeos")'
RUN R -e 'install.packages("sandwich")'
RUN R -e 'install.packages("sf")'
RUN R -e 'install.packages("stats")'
RUN R -e 'install.packages("stringr")'
RUN R -e 'install.packages("tictoc")'
RUN R -e 'install.packages("tidyverse")'
RUN R -e 'install.packages("zoo")'
RUN R -e 'install.packages("lmtest")'
RUN R -e 'install.packages("rmarkdown")'

RUN apt-get install -y strace
COPY Rprofile.R /root/.Rprofile
WORKDIR /workspace

ENTRYPOINT ["/usr/bin/Rscript"]
