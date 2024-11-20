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

In v2, where possible we install binary R packages for Linux from the Posit Public Package Manager.

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

If you need to install a package from another CRAN-like repository, specify its URL as the REPOS argument.

```sh
just add-package PACKAGE REPOS
```

This will attempt to install and build the package and its dependencies, and
update the `v1/renv.lock`. It will then rebuild the R image with the new lock file
and test it.

Note that the first time you do this it will need to compile every
included R package (because you won't have the R package builds cached
locally). This can take **several hours**. (When we solve the caching
problem here we'll be able to do this all in CI.)

#### Under v2

Add the package to _v2/packages.csv_. In this file, the first column is the package name, and the second column is for the repository. If the package is on CRAN simply leave the second column blank after the comma. If the package is not on CRAN please add it to the <https://opensafely-core.r-universe.dev> by adding it to the _packages.json_ file in <https://github.com/opensafely-core/opensafely-core.r-universe.dev>, then enter the relevant Linux binary package URL, likely `https://opensafely-core.r-universe.dev/bin/linux/noble/4.4/`.

If the package requires any runtime dependencies add those to _v2/dependencies.txt_

Then build the v2 image.

```sh
just build v2
```

### Push the new Docker image to Github Container Registry

You will need to configure authentication to GitHub's container registry first.
See [GitHub's documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry).

When you have authentication configured, run:

```sh
just publish VERSION
```

### Commit changes to this repository

Commit and push the small resulting change (should only be a few extra
lines in `VERSION/packages.csv`, `VERSION/packages.md`, and `VERSION/renv.lock`) to a branch, then get the changes
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
just add-package v1 PACKAGE@VERSION
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

## How to update the version of R and the packages

In v2, we choose a date from which to install the packages from CRAN, we strongly recommend that the version of R in the image was the release version of R on this date. R release dates can be found on the [R wikipedia page](https://en.wikipedia.org/wiki/R_(programming_language)#Version_names).

In v2, when installing packages we use a Posit Public Package Manager (PPPM) snapshot repository on the chosen `CRAN_DATE`.

We use a fixed date because CRAN follows a rolling release model.
As such we know that on a particular date CRAN has tested these package versions with the release version of R.
Hence this is an extremely stable approach to choosing a set of package versions.
And we can add additional packages at their versions on this date reliably (and without updating dependency packages already included in the image).

The CRAN apt repository for R is available [here](https://cran.r-project.org/bin/linux/ubuntu/noble-cran40/) (note you may need to amend the Ubuntu codename in the URL if using a newer base image), find the package number you require and edit the number in _v2/dependencies.txt_ and _v2/build-dependencies.txt_.

Then amend the `CRAN_DATE` and `REPOS` arguments in _v2/env_.

To update run

```sh
just build v2
```

To test the updated image run

```sh
just test v2
```

### How to choose a version of R and CRAN date

Choose a version of R.

Choose a CRAN date when that version of R.

Essentially we follow a very similar approach to the versioned stack of the Rocker project. They list their R versions and CRAN dates on their [wiki](https://github.com/rocker-org/rocker-versioned2/wiki/Versions).

We recommend not choosing a date within the first week of a new version of R being released, because there may be alot of packages updated on CRAN during this time.

You then need to check that a PPPM snapshot repository exists for your chosen date. Navigate to <https://p3m.dev/client/#/repos/cran/setup> and inspect your chosen date. Set this as the `REPOS` argument in _v2/env_.

If you choose a version of R that is not the current version of R we recommend following the rocker approach and choosing the CRAN date as the day before the next version of R was released. For example, if choosing R 4.4.1, R 4.4.2 was released on 2024-10-31 and so we would choose 2024-10-30 as the CRAN date.

You can find out when the next release of R is scheduled for on the [R developer page](https://developer.r-project.org/).

We set the `HTTPUserAgent` in the appropriate places so that we obtain binary R packages for Linux from the PPPM. There is additional information about this on the [PPPM website](https://p3m.dev/__docs__/admin/serving-binaries/#binary-user-agents).
