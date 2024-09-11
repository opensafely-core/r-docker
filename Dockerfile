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
    RENV_PATHS_SANDBOX=/renv/sandbox \
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

FROM r as rstudio

# Install rstudio-server (and a few dependencies)
RUN apt-get update &&\
    # drop sudo??, drop gdebi-core??, drop libclang-dev??
    apt-get install -y wget gdebi-core psmisc libclang-dev sudo &&\
    wget https://download2.rstudio.org/server/focal/amd64/rstudio-server-2024.04.2-764-amd64.deb &&\
    # dpkg -i rstudio-server-2024.04.2-764-amd64.deb
    ## try: apt install --no-install-recommends ./rstudio-server-2024.04.2-764-amd64.deb
    apt install ./rstudio-server-2024.04.2-764-amd64.deb &&\
    # delete the deb
    rm rstudio-server-2024.04.2-764-amd64.deb &&\
    # Setup rstudio user, disable rstudio-server authentication, and use renv R packages
    # Remembering that the second renv library directory /renv/sandbox/R-4.0/x86_64-pc-linux-gnu/9a444a72 
    # contains 14 symlinks to 14 of the 15 packages in ${R_HOME}/library which is /usr/lib/R/library/
    # From https://github.com/opensafely-core/research-template-docker/blob/5f857e5ec2beb55327075c13c26b51e1accaeb0b/Dockerfile#L43C1-L47C56 with modifications
    useradd rstudio &&\
    echo "auth-none=1" >> /etc/rstudio/rserver.conf &&\
    echo "USER=rstudio" >> /etc/environment &&\
    # Give the local user sudo (aka root) permissions
    ## usermod -aG sudo rstudio &&\
    ## echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers &&\
    # Add a home directory for the rstudio user
    mkdir /home/rstudio &&\
    chown -R rstudio /home/rstudio/ &&\
    echo "R_LIBS_SITE=/renv/lib/R-4.0/x86_64-pc-linux-gnu" > /home/rstudio/.Renviron

## ENV USER rstudio
USER rstudio

## or amend ENTRYPOINT
ENV ACTION_EXEC="rstudio-server start"
