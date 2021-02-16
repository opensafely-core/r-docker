Note: this Dockerfile is currently broken - do not build.

Temporarily, we are adding packages hackily to the existing docker image
and pushing updates.

To add a new package run:

    ./add-pkg.sh [PACKAGE_NAME]

This will install the package in a layer on top of the existing image, and then tag that
image locally as ghcr.io/opensafely-core/r. It then tests that all packages in
packages.txt can be loaded without error. If so, it adds the new package to
packages.txt and regenerates packages.csv.

You can then do `docker push ghcr.io/opensafely-core/r` to publish it.
