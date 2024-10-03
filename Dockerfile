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

#################################################
#
# Add rstudio-server to r image - creating rstudio image
FROM r as rstudio

COPY rstudio-dependencies.txt /root/rstudio-dependencies.txt

# Install rstudio-server (and a few dependencies)
RUN --mount=type=cache,target=/var/cache/apt /root/docker-apt-install.sh /root/rstudio-dependencies.txt &&\
    wget -q -O rstudio-server.deb https://download2.rstudio.org/server/focal/amd64/rstudio-server-2024.09.0-375-amd64.deb &&\
    apt-get install --no-install-recommends -y ./rstudio-server.deb &&\
    # delete the deb
    rm rstudio-server.deb &&\
    # Setup rstudio user using approach in opensafely-core/research-template-docker
    useradd rstudio &&\
    # Disable rstudio-server authentication
    echo "auth-none=1" >> /etc/rstudio/rserver.conf &&\
    # Run the server under the single user account
    echo "server-user=rstudio" >> /etc/rstudio/rserver.conf &&\
    echo "USER=rstudio" >> /etc/environment &&\
    # Give the rstudio user sudo (aka root) permissions
    usermod -aG sudo rstudio &&\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers &&\
    # Add a home directory for the rstudio user
    mkdir /home/rstudio &&\
    chown -R rstudio:rstudio /home/rstudio/ &&\
    # Use renv R packages
    # Remember that the second renv library directory /renv/sandbox/R-4.0/x86_64-pc-linux-gnu/9a444a72
    # contains 14 symlinks to 14 of the 15 packages in ${R_HOME}/library which is /usr/lib/R/library/
    # so that is already setup
    echo "R_LIBS_SITE=/renv/lib/R-4.0/x86_64-pc-linux-gnu" >> /usr/lib/R/etc/Renviron.site &&\
    # open RStudio in /workspace
    echo "session-default-working-dir=/workspace" >> /etc/rstudio/rsession.conf

COPY rstudio-entrypoint.sh /usr/local/bin/rstudio-entrypoint.sh

# Make entrypoint script executable
RUN chmod +x /usr/local/bin/rstudio-entrypoint.sh

ENV USER rstudio
ENTRYPOINT ["/usr/local/bin/rstudio-entrypoint.sh"]
