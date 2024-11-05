# r-docker

Docker image for running R code in OpenSAFELY, both locally and in production.

## Installation requirements to build this image

* docker
* docker-compose
* [just](https://github.com/casey/just)

## Building

```sh
just build
```

Under the hood, this builds `./Dockerfile` using docker-compose and buildkit.

We currently build a lot of packages, so an initial build on a fresh checkout
can take a long time (e.g. an hour).  However, to alleviate this, the
Dockerfile is carefully designed to use local buildkit cache, so subequent
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

To add a package, it must be available on CRAN. We cannot currently install
things from Github or other locations.

```sh
just add-package PACKAGE
```

This will attempt to install and build the package and its dependencies, and
update the `renv.lock`. It will then rebuild the R image with the new lock file
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
just publish
```

### Commit changes to this repository

Commit and push the small resulting change (should only be a few extra
lines in `packages.csv` and `renv.lock`) to a branch, then get the changes
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
headers), they should be added to `build-dependencies.txt`. If it requires
runtime dependencies, they should be added to `dependencies.txt`. Packages
don't advertise their system dependencies, so you may need to figure them out
by trying to add the package and reading any error output on failure.
Note that the Public Posit Package Manager provides a list of apt dependencies for CRAN packages.

#### Installing an older version

If the package still fails to build, you may be able to install an older version.

Find a previous version at `https://cran.r-project.org/src/contrib/Archive/{PACKAGE}/`, and attempt to install it specifically with

```sh
just add-package PACKAGE@VERSION
```

## Building, testing, and publishing the rstudio image

The rstudio image is based on the r image including rstudio-server. To build run

```sh
just build-rstudio
```

To test that rstudio-server appears at `http://localhost:8787` run

```sh
just test-rstudio
```

And then push the new rstudio image to the GitHub container registry with

```sh
just publish-rstudio
```

## How to update the version of R and the packages

In the second iteration of the r image we choose a date from which to install the packages from CRAN, the version of R in the image must have been the release version of R on this date.

R release dates can be found on the [R wikipedia page](https://en.wikipedia.org/wiki/R_(programming_language)#Version_names).

When installing packages we use a Posit Public Package Manager (PPPM) snapshot repository on the chosen `CRAN_DATE`.

We use a fixed date because CRAN follows a rolling release model.
As such we know that on a particular date CRAN has tested these package versions on this version of R.
Hence this is an extremely stable approach.
And we can add additional packages at their versions on this date reliably (and without updating dependency packages already included in the image).

The CRAN apt repository for R is available [here](https://cran.r-project.org/bin/linux/ubuntu/noble-cran40/) (note you may need to amend the Ubuntu codename in the URL if using a newer base image), find the package number you require and edit the number in _dependencies.txt_ and _build-dependencies.txt_.

Then amend the `CRAN_DATE` and `REPOS` arguments in _build.sh_.

To update run

```sh
just build update
```

To test the updated image run

```sh
just test-update
```

To build without updating simply run

```sh
just build
```

### How to choose a version of R and CRAN date

Choose a version of R.

Choose a CRAN date when that version of R 

Essentially we follow a very similar approach to the versioned stack of the Rocker project. They list their R versions and CRAN dates on their [wiki](https://github.com/rocker-org/rocker-versioned2/wiki/Versions).

We recommend not choosing a date within the first week of a new version of R being released, because there may be alot of packages updated on CRAN during this time.

You then need to check that a PPPM snapshot repository exists for your chosen date. Navigate to <https://p3m.dev/client/#/repos/cran/setup> inspect your chosen date. Set this as the `REPOS` argument in _build.sh_.

If you choose a version of R that is not the current version of R we recommend following the rocker approach and choosing the CRAN date as the day before the next version of R was released. For example, if choosing R 4.4.1, R 4.4.2 was released on 2024-10-31 and so we choose 2024-10-30 as the CRAN date.

You can find out when the next release of R is scheduled for on the [R developer page](https://developer.r-project.org/).

We set the `HTTPUserAgent` in the appropriate places so that we obtain binary R packages for Linux from the PPPM. There is additional information about this on the [PPPM website](https://p3m.dev/__docs__/admin/serving-binaries/#binary-user-agents).
