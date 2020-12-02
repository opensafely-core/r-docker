Note: this Dockerfile is currently broken - do not build.

Temporarily, we are adding packages hackily to the existing docker image
and pushing updates.

To do so, add the package to the current Dockerfile as renv::install,
just to keep track of it.


Then run:

    ./add-pkg.sh [PACKAGE_NAME]

This will install the package on the existing image, and then save that
image, and test the package installation has worked.

You can then push the updated docker image.

