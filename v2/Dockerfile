# syntax=docker/dockerfile:1.11
# enable docker linting
# check=error=true
#
#################################################
ARG BASE=22.04
FROM ghcr.io/opensafely-core/base-action:$BASE AS base-r
ARG MAJOR_VERSION=v2

# add cran repo for R packages and install
RUN --mount=type=cache,target=/var/cache/apt,id=apt-2204,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,id=apt-2204,sharing=locked \
    --mount=type=bind,source=${MAJOR_VERSION}/dependencies.txt,target=/tmp/dependencies.txt <<EOF
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" > /etc/apt/sources.list.d/cran.list
    /usr/lib/apt/apt-helper download-file 'https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc' /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
    /root/docker-apt-install.sh /tmp/dependencies.txt
EOF

# use pak to install packages
ENV PKG_CACHE_DIR=/cache/main
ENV PKG_PACKAGE_CACHE_DIR=/cache/package
ENV PKG_METADATA_CACHE_DIR=/cache/metadata
ARG REPOS="default-arg-to-silence-docker"
ARG CRAN_DATE="default-arg-to-silence-docker"
RUN --mount=type=cache,target=/cache,id=/cache-2204,sharing=locked \
    --mount=type=bind,source=scripts/build-toml.R,target=/tmp/scripts/build-toml.R \
    --mount=type=bind,source=${MAJOR_VERSION}/packages.toml,target=/tmp/packages.toml \
    Rscript /tmp/scripts/build-toml.R


################################################
#
# Finally, build the actual image from the base-r image
FROM base-r AS r

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


#################################################
#
# Add rstudio-server to r image - creating rstudio image
ARG RSTUDIO_BASE_URL="default-arg-to-silence-docker"
ARG RSTUDIO_DEB="default-arg-to-silence-docker"
FROM r AS rstudio

# Install rstudio-server (and a few dependencies)
COPY rstudio/rstudio-dependencies.txt /root/rstudio-dependencies.txt
RUN --mount=type=cache,target=/var/cache/apt,id=apt-2204,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,id=apt-2204,sharing=locked \
    --mount=type=bind,source=rstudio/rstudio-dependencies.txt,target=/tmp/rstudio-dependencies.txt <<EOF
    /root/docker-apt-install.sh /tmp/rstudio-dependencies.txt
    test -f /var/cache/apt/"${RSTUDIO_DEB}" || /usr/lib/apt/apt-helper download-file "${RSTUDIO_BASE_URL}${RSTUDIO_DEB}" /var/cache/apt/"${RSTUDIO_DEB}"
    apt-get install --no-install-recommends -y /var/cache/apt/"${RSTUDIO_DEB}"
EOF

# Configuration
## Start by setting up rstudio user using approach in opensafely-core/research-template-docker
RUN useradd rstudio -m
# copy R/rstudio config into user home dir
COPY rstudio/home/* /home/rstudio/
COPY rstudio/etc/* /etc/rstudio/

RUN <<EOF
    chown -R rstudio:rstudio /home/rstudio
    echo "R_LIBS_SITE=/usr/local/lib/R/site-library" >> /usr/lib/R/etc/Renviron.site
EOF

COPY rstudio/rstudio-entrypoint.sh /usr/local/bin/rstudio-entrypoint.sh

ENV USER rstudio
ENTRYPOINT ["/usr/local/bin/rstudio-entrypoint.sh"]
