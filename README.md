# r-docker

Docker image for running R scripts in OpenSAFELY.

Note: this Dockerfile is currently broken - do not build.

## Adding packages

Temporarily, we are adding packages hackily to the existing docker image and
pushing updates.

We are not currently auditing packages added, we are trusting the requester.
Users can already ship and run arbitrary code in this docker image.

To add a new package, first pull the latest image:

    docker pull ghcr.io/opensafely-core/r

then run the tests to check that all is well:

    ./test.sh


To add an R package, run:

    ./add-pkg.sh r PACKAGE_NAME [REPO]

To add a system package run:

    ./add-pkg.sh apt PACKAGE_NAME

This will install the requested package in a layer on top of the existing
image, and then tag that image locally as ghcr.io/opensafely-core/r. It then
tests that all packages in packages.txt can be loaded without error. 

For R packages, it adds the new package to packages.txt and regenerates
packages.csv.

You can then do `docker push ghcr.io/opensafely-core/r` to publish it.


Note: this could be automated, but we are wary of this, due to unintended
upgrades of libraries, so we do it by hand currently.
