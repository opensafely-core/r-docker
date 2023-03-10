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

**WARNING!** To do this you will need:
 * Enough bandwidth to comfortably push potentionally gigabytes worth of
   Docker layers.
 * Several hours worth of CPU time to re-compile all the packages (if
   this is the first time you've done this and don't have them cached
   locally).
 * Push access to ghcr.io.

If you don't have all these things then please don't start.

### Install it

To add a package, it must be available on CRAN. We cannot currently install
things from Github or other locations.
```
just add-package PACKAGE
```

This will attempt to install and build the package and its dependencies, and
update the `renv.lock`. It will then rebuild the R image with the new lock file
and test it.

Note that the first time you do this it will need to compile every
included R package (because you won't have the R package builds cached
locally). This can take **several hours**. (When we solve the caching
problem here we'll be able to do this all in CI.)

### Push to Github Container Registry

Run:
```
just publish
```

### Commit changes

Commit and push the small resulting change (should only be a few extra
lines in `packages.csv` and `renv.lock`).

You may as well push this direct to `main`; there's no point getting it
reviewed because you've just pushed the built image direct to the
Docker registry in any case.

### Deploy new image

The updated image will need pulling into production. This is covered
separately in the tech team manual. If you don't have access, ask in
`#tech`.


### Trouble shooting

####  System dependencies

If the package requires any system build dependencies (e.g. -dev packages with
headers), they should be added to `build-dependencies.txt` If it requires
runtime dependencies, they should be added to `dependencies.txt`.  Packages
don't advertise their system dependencies, so you may need to figure them out
by trying to add the package and reading any error output on failure.


#### Installing an older version

If the package still fails to build, you may be able to install an older version.

Find a previous version at `https://cran.r-project.org/src/contrib/Archive/{PACKAGE}/`, and attempt to install it specifically with

```
just add-package PACKAGE@VERSION
```
