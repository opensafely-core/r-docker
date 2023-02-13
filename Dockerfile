# syntax=docker/dockerfile:1.2
#################################################
#
# We need base r dependencies on both the builder and r images, so
# create base image with those installed to save installing them twice.
FROM ghcr.io/opensafely-core/base-action:20.04 as base-r

COPY dependencies.txt /root/dependencies.txt

# add cran repo for R packages and install
RUN --mount=type=cache,target=/var/cache/apt \
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" > /etc/apt/sources.list.d/cran.list &&\
    /usr/lib/apt/apt-helper download-file 'https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc' /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc &&\
    /root/docker-apt-install.sh /root/dependencies.txt

ENV RENV_PATHS_LIBRARY=/renv/lib \
    RENV_PATHS_LOCKFILE=/renv/renv.lock

#################################################
#
# Next, use the base-docker-plus-r image to create a build image
FROM base-r as builder

# install build time dependencies 
COPY build-dependencies.txt /root/build-dependencies.txt
RUN --mount=type=cache,target=/var/cache/apt /root/docker-apt-install.sh /root/build-dependencies.txt

RUN mkdir -p /cache /renv/lib

# Build a full arrow package, specifically for zstd compression, but also because its good.
# The renv cache paths use /cache, which should be mounted as a reusable build-time cache dir.
ENV RENV_PATHS_SOURCE=/cache/source \
    RENV_PATHS_BINARY=/cache/binary \
    RENV_PATHS_CACHE=/cache/cache \
    LIBARROW_MINIMAL=false

WORKDIR /renv

# install renv
RUN --mount=type=cache,target=/cache,id=/cache-2004 R -e 'install.packages("renv", destdir="/cache"); renv::init(bare = TRUE)'

# use renv to install packages
COPY renv.lock /renv/renv.lock
RUN --mount=type=cache,target=/cache,id=/cache-2004 R -e 'renv::restore()'

# renv uses symlinks to the the build cache to populate the lib directory. As
# our cache is mounted only at build (so we can do fast rebuilds), we need to
# change the symlinks into full copies, to store them in the image.
COPY copy-symlink.sh /tmp/copy-symlink.sh
RUN --mount=type=cache,target=/cache,id=/cache-2004 bash /tmp/copy-symlink.sh /renv/lib


###############################################
#
# This stage exists to allow installing a new package. 
#
# Building it explicitly with --target add-package will build and install the
# package supplied by PACKAGE build arg. We do at as a build stage so we can
# reuse and populate the build cache.  It will then update the renv.lock file,
# include the cache hashes.  This renv.lock file is copied off this built image
# by the project tooling.  This will then make normal image build a) use the
# new renv.lock file and b) re-use the prepopulated cached build from building
# this special layer.
FROM builder as add-package

ARG PACKAGE="default-arg-to-silence-docker"
# install the package using the cache
RUN --mount=type=cache,target=/cache,id=/cache-2004 bash -c "R -e 'renv::activate(); renv::install(\"$PACKAGE\"); renv::snapshot(type=\"all\")'"


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

# setup /workspace
RUN mkdir /workspace
WORKDIR /workspace

# copy the renv over from the builder image
COPY --from=builder /renv /renv
# this will ensure the renv is activated by default
RUN echo 'source("/renv/renv/activate.R")' >> /etc/R/Rprofile.site
