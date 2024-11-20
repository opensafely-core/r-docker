# syntax=docker/dockerfile:1.2
#################################################
#
# We need base r dependencies on both the builder and r images, so
# create base image with those installed to save installing them twice.
FROM ghcr.io/opensafely-core/base-action:24.04 as base-r

COPY v2/dependencies.txt /root/dependencies.txt

# add cran repo for R packages and install
RUN --mount=type=cache,target=/var/cache/apt \
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" > /etc/apt/sources.list.d/cran.list &&\
    /usr/lib/apt/apt-helper download-file 'https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc' /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc &&\
    /root/docker-apt-install.sh /root/dependencies.txt

ENV RENV_PATHS_LIBRARY=/renv/lib \
    RENV_PATHS_SANDBOX=/renv/sandbox \
    RENV_PATHS_LOCKFILE=/renv/renv.lock

#################################################
#
# Next, use the base-docker-plus-r image to create a build image
FROM base-r as builder
ARG MAJOR_VERSION="default-arg-to-silence-docker"

# install build time dependencies 
COPY v2/build-dependencies.txt /root/build-dependencies.txt
RUN --mount=type=cache,target=/var/cache/apt /root/docker-apt-install.sh /root/build-dependencies.txt

RUN mkdir -p /cache /renv/lib

# Build a full arrow package, specifically for zstd compression, but also because its good.
# The renv cache paths use /cache, which should be mounted as a reusable build-time cache dir.
ENV RENV_PATHS_SOURCE=/cache/source \
    RENV_PATHS_BINARY=/cache/binary \
    RENV_PATHS_CACHE=/cache/cache \
    LIBARROW_MINIMAL=false

WORKDIR /renv

# use renv to install packages
ARG UPDATE="default-arg-to-silence-docker"
ARG REPOS="default-arg-to-silence-docker"
ARG CRAN_DATE="default-arg-to-silence-docker"
COPY ${MAJOR_VERSION}/renv.lock /renv/renv.lock
# Update
COPY scripts/update.R /root/update.R
RUN --mount=type=cache,target=/cache,id=/cache-2404 if [ "$UPDATE" = "true" ]; then Rscript /root/update.R; fi
# Alternatively build without updating
# For v2 new packages added here also
ARG PACKAGE
COPY scripts/restore.R /root/restore.R
RUN --mount=type=cache,target=/cache,id=/cache-2404 if [ "$UPDATE" = "false" ]; then Rscript /root/restore.R; fi

# renv uses symlinks to the the build cache to populate the lib directory. As
# our cache is mounted only at build (so we can do fast rebuilds), we need to
# change the symlinks into full copies, to store them in the image.
COPY scripts/copy-symlink.sh /tmp/copy-symlink.sh
RUN --mount=type=cache,target=/cache,id=/cache-2404 bash /tmp/copy-symlink.sh /renv/lib


################################################
#
# Finally, build the actual image from the base-r image
FROM base-r as r

# Some static metadata for this specific image, as defined by:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys
# The org.opensafely.action label is used by the jobrunner to indicate this is
# an approved action image to run.
LABEL org.opencontainers.image.title="r" \
      org.opencontainers.image.description="R action for opensafely.org" \
      org.opencontainers.image.source="https://github.com/opensafely-core/r-docker" \
      org.opensafely.action="r"

# ACTION_EXEC is our default executable
ENV ACTION_EXEC="/usr/bin/Rscript"
# INTERACTIVE_EXEC is used when running w/o any args, implying an interactive session.
# See: https://github.com/opensafely-core/base-docker/blob/main/entrypoint.sh#L5
ENV INTERACTIVE_EXEC="/usr/bin/R"

# setup /workspace
RUN mkdir /workspace
WORKDIR /workspace

# copy the renv over from the builder image
COPY --from=builder /renv /renv
# this will ensure the renv is activated by default
RUN echo 'options(renv.config.synchronized.check = FALSE, renv.config.startup.quiet = TRUE)' >> /etc/R/Rprofile.site &&\
    echo 'source("/renv/renv/activate.R")' >> /etc/R/Rprofile.site

#################################################
#
# Add rstudio-server to r image - creating rstudio image
ARG RSTUDIO_BASE_URL="default-arg-to-silence-docker"
ARG RSTUDIO_DEB="default-arg-to-silence-docker"
FROM r as rstudio

# Install rstudio-server (and a few dependencies)
COPY rstudio/rstudio-dependencies.txt /root/rstudio-dependencies.txt
RUN --mount=type=cache,target=/var/cache/apt /root/docker-apt-install.sh /root/rstudio-dependencies.txt &&\
    test -f /var/cache/apt/"${RSTUDIO_DEB}" ||\
    /usr/lib/apt/apt-helper download-file "${RSTUDIO_BASE_URL}${RSTUDIO_DEB}" /var/cache/apt/"${RSTUDIO_DEB}" &&\
    apt-get install --no-install-recommends -y /var/cache/apt/"${RSTUDIO_DEB}"

# Configuration
## Start by setting up rstudio user using approach in opensafely-core/research-template-docker
RUN useradd rstudio -m
# copy R/rstudio config into user home dir
COPY rstudio/home/* /home/rstudio/
COPY rstudio/etc/* /etc/rstudio/

RUN chown -R rstudio:rstudio /home/rstudio &&\
    # Use renv R packages
    # Remember that the second renv library directory /renv/sandbox/R-4.0/x86_64-pc-linux-gnu/9a444a72
    # contains 14 symlinks to 14 of the 15 packages in ${R_HOME}/library which is /usr/lib/R/library/
    # so that is already setup
    echo "R_LIBS_SITE=/renv/lib/linux-ubuntu-noble/R-4.4/x86_64-pc-linux-gnu" >> /usr/lib/R/etc/Renviron.site

COPY rstudio/rstudio-entrypoint.sh /usr/local/bin/rstudio-entrypoint.sh

ENV USER rstudio
ENTRYPOINT ["/usr/local/bin/rstudio-entrypoint.sh"]
