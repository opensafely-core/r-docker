# syntax=docker/dockerfile:1.11
# enable docker linting
# check=error=true
#
#################################################
# We need base r dependencies on both the builder and r images, so
# create base image with those installed to save installing them twice.
FROM ghcr.io/opensafely-core/base-action:24.04 as base-r
ARG MAJOR_VERSION=v2

# add cran repo for R packages and install
RUN --mount=type=cache,target=/var/cache/apt,id=apt-2404,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,id=apt-2404,sharing=locked \
    --mount=type=bind,source=${MAJOR_VERSION}/dependencies.txt,target=/tmp/dependencies.txt <<EOF
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" > /etc/apt/sources.list.d/cran.list
    /usr/lib/apt/apt-helper download-file 'https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc' /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
    /root/docker-apt-install.sh /tmp/dependencies.txt
EOF

ENV RENV_PATHS_LIBRARY=/renv/lib \
    RENV_PATHS_SANDBOX=/renv/sandbox \
    RENV_PATHS_LOCKFILE=/renv/renv.lock

#################################################
#
# Next, use the base-docker-plus-r image to create a build image
FROM base-r as builder

# install build time dependencies 

RUN --mount=type=cache,target=/var/cache/apt,id=apt-2404,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,id=apt-2404,sharing=locked \
    --mount=type=bind,source=${MAJOR_VERSION}/build-dependencies.txt,target=/tmp/build-dependencies.txt \
    /root/docker-apt-install.sh /tmp/build-dependencies.txt

RUN mkdir -p /cache /renv/lib

# Build a full arrow package, specifically for zstd compression, but also because its good.
# The renv cache paths use /cache, which should be mounted as a reusable build-time cache dir.
ENV RENV_PATHS_SOURCE=/cache/source \
    RENV_PATHS_BINARY=/cache/binary \
    RENV_PATHS_CACHE=/cache/cache \
    LIBARROW_MINIMAL=false

WORKDIR /renv

# use renv to install packages
# renv uses symlinks to the the build cache to populate the lib directory. As
# our cache is mounted only at build (so we can do fast rebuilds), we need to
# change the symlinks into full copies, to store them in the image.
ARG REPOS="default-arg-to-silence-docker"
ARG CRAN_DATE="default-arg-to-silence-docker"
RUN --mount=type=cache,target=/cache,id=/cache-2404,sharing=locked \
    --mount=type=bind,source=scripts/,target=/tmp/scripts/ \
    --mount=type=bind,source=${MAJOR_VERSION}/packages.csv,target=/tmp/packages.csv <<EOF
    Rscript /tmp/scripts/build.R
    bash /tmp/scripts/copy-symlink.sh /renv/lib
EOF

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
      org.opensafely.action="r" \
      org.opensafely.version="${MAJOR_VERSION}" \
      org.opensafely.cran-date="${CRAN_DATE}"

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
RUN <<EOF
    echo 'options(renv.config.synchronized.check = FALSE, renv.config.startup.quiet = TRUE)' >> /etc/R/Rprofile.site
    echo 'source("/renv/renv/activate.R")' >> /etc/R/Rprofile.site
EOF

#################################################
#
# Add rstudio-server to r image - creating rstudio image
ARG RSTUDIO_BASE_URL="default-arg-to-silence-docker"
ARG RSTUDIO_DEB="default-arg-to-silence-docker"
FROM r as rstudio

# Install rstudio-server (and a few dependencies)
COPY rstudio/rstudio-dependencies.txt /root/rstudio-dependencies.txt
RUN --mount=type=cache,target=/var/cache/apt,id=apt-2404,sharing=locked /root/docker-apt-install.sh /root/rstudio-dependencies.txt &&\
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
    echo "R_LIBS_SITE=/renv/lib/linux-ubuntu-noble/R-4.4/x86_64-pc-linux-gnu" >> /usr/lib/R/etc/Renviron.site &&\
    # Remove renv activation lines from Rprofile.site because we set R_LIBS_SITE
    head -n -2 /etc/R/Rprofile.site > tmp.txt && mv tmp.txt /etc/R/Rprofile.site

COPY rstudio/rstudio-entrypoint.sh /usr/local/bin/rstudio-entrypoint.sh

ENV USER rstudio
ENTRYPOINT ["/usr/local/bin/rstudio-entrypoint.sh"]
