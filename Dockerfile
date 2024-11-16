FROM ghcr.io/opensafely-core/r@sha256:4b075ecfd435e5d25c7d76ce2513c93c2d05b07925037264016b395de50fecef AS r-image
FROM rocker/r-ver:4.0.5
RUN apt-get update && apt-get install --no-install-recommends -y libnode-dev \
    libcurl4-gnutls-dev git cmake libgdal-dev libjpeg-dev libmagick++-dev \
    libpng-dev librsvg2-dev libssl-dev libudunits2-dev libxml2-dev unixodbc-dev \
    tzdata pandoc
COPY --from=r-image /renv/lib/R-4.0/x86_64-pc-linux-gnu /usr/local/lib/R/site-library
RUN R -e "install.packages('dagitty', dependencies = FALSE); remotes::install_github('wjchulme/dd4d', dependencies = FALSE)"
# setup /workspace
RUN mkdir /workspace
WORKDIR /workspace
# ACTION_EXEC is our default executable
ENV ACTION_EXEC="/usr/local/bin/Rscript"
# INTERACTIVE_EXEC is used when running w/o any args, implying an interactive session.
# See: https://github.com/opensafely-core/base-docker/blob/main/entrypoint.sh#L5
ENV INTERACTIVE_EXEC="/usr/local/bin/R"
