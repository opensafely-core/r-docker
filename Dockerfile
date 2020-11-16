FROM ghcr.io/opensafely/base-docker

# This next section is adapted from https://hub.docker.com/r/continuumio/miniconda3/dockerfile
# We do not use that image directly as we want a different base layer
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    PATH=/opt/conda/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/London

# install OS dependencies and clean up afterwards
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git software-properties-common tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install pinned version of miniconda and clean up
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean --all --yes && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate r" >> ~/.bashrc

# install our packages and clean up
COPY packages.txt /opt/packages.txt
RUN conda create --name r --file /opt/packages.txt --channel r --channel conda-forge && \
    conda clean --all --yes

WORKDIR /workspace
ENTRYPOINT ["/opt/conda/envs/r/bin/Rscript"]
CMD [ "/bin/bash" ]
