# r-docker

Docker image for running R code in OpenSAFELY, both locally and in production.

## Installation requirements to build this image

* docker
* docker-compose
* [just](https://github.com/casey/just)

And the tests additionally require

* curl
* python3

## Building

```sh
just build VERSION
```

where `VERSION` is either v1 or v2.

Under the hood, this builds `VERSION/Dockerfile` using docker-compose and buildkit.

In v1, we currently build a lot of packages, so an initial build on a fresh checkout
can take a long time (e.g. an hour).  However, to alleviate this, the
v1/Dockerfile is carefully designed to use local buildkit cache, so subequent
rebuilds should be very fast.

## Adding new packages

:warning: To do this you will need:

 * Enough bandwidth to comfortably push potentionally gigabytes worth of
   Docker layers.
 * Several hours worth of CPU time to re-compile all the packages (if
   this is the first time you've done this and don't have them cached
   locally).
 * Push access to ghcr.io.

If you don't have all these things then please don't start.

### Confirm that the package is suitable to add

Before adding a package, check with an OpenSAFELY team member with R
experience to approve the package.

### Install the package within Docker

#### Under v1

To add a package, by default it will be installed from CRAN.

```sh
just add-package-v1 PACKAGE
```

If you need to install a package from another CRAN-like repository, specify its URL as the REPOS argument.

```sh
just add-package-v1 PACKAGE REPOS
```

This will attempt to install and build the package and its dependencies, and
update the `v1/renv.lock`. It will then rebuild the R image with the new lock file
and test it.

Note that the first time you do this it will need to compile every
included R package (because you won't have the R package builds cached
locally). This can take **several hours**. (When we solve the caching
problem here we'll be able to do this all in CI.)

### Push the new Docker image to Github Container Registry

You will need to configure authentication to GitHub's container registry first.
See [GitHub's documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry).

When you have authentication configured, run:

```sh
just publish VERSION
```

### Commit changes to this repository

Commit and push the small resulting change (should only be a few extra
lines in `v1/packages.csv`, `VERSION/packages.md`, and `v1/renv.lock`) to a branch, then get the changes
merged via pull request.

The review is a trivial exercise because the Docker image has already been
pushed to GitHub.

### Deploy the new Docker image

The updated image will need pulling into production. This is covered
separately in the tech team manual. If you don't have access, ask in
`#tech`.

### Troubleshooting

#### System dependencies

If the package requires any system build dependencies (e.g. -dev packages with
headers), they should be added to `VERSION/build-dependencies.txt`. If it requires
runtime dependencies, they should be added to `VERSION/dependencies.txt`. Packages
don't advertise their system dependencies, so you may need to figure them out
by trying to add the package and reading any error output on failure.

#### Installing an older version in the v1 image only

If the package still fails to build, you may be able to install an older version.

Find a previous version at `https://cran.r-project.org/src/contrib/Archive/{PACKAGE}/`, and attempt to install it specifically with

```sh
just add-package-v1 PACKAGE@VERSION
```

## Building, testing, and publishing the rstudio image

The rstudio image is based on the r image including rstudio-server. To build run

```sh
just build-rstudio VERSION
```

To test that rstudio-server appears at `http://localhost:8787` run

```sh
just test-rstudio VERSION
```

And then push the new rstudio image to the GitHub container registry with

```sh
just publish-rstudio VERSION
```
