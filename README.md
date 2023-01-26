# r-docker

Docker image for running R code in OpenSAFELY, both locally and in production.

## Requirements

You will need docker, docker-compose and [just](https://github.com/casey/just) installed.


## Building

`just build`

Under the hood, this builds `./Dockerfile` using docker-compose and buildkit.

We currently build a lot of packages, so an initial build on a fresh checkout
can take a long time (e.g. an hour).  However, to alleviate this, the
Dockerfile is carefully designed to use local buildkit cache, so subequent
rebuilds should be very fast.


## Adding new packages

To add a package, it must be available on CRAN. We cannot currently install
things from Github or other locations.

Additionally, if the package requires any build dependencies (e.g. -dev
packages with headers), they should be added to `build-dependencies.txt` If it
requires runtime dependencies, they should be added to `dependencies.txt`.


`just add-package PACKAGE` 

or 

`just add-package PACKAGE@VERSION`


This will attempt to install and build the package and its dependencies, and
update the `renv.lock`. It will then rebuild the R image with the new lock file
and test it.
