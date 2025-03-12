# OpenSAFELY R Runtime Image

This repo manages the Docker image for the OpenSAFELY R and rstudio-server runtime. These
images are based on a base Ubuntu LTS version, and come pre-installed with
a set of standard R packages.

The current latest version is `v2`, and you should use that unless you have
a specific reason. You can use it in your `project.yaml` like so:

```
actions:
  my_action:
    run: r:v2 my_script.R ...
```

## Version List

Current available versions, in reverse chronological order:

 - v2: Ubuntu 22.04 and R 4.4.3 - [full package list](v2/packages.md)
 - v1: Ubuntu 20.04 and R 4.0.5 - [full package list](v1/packages.md)

### Legacy version: `latest`

Initially, OpenSAFELY only had one version of the r image. This is the
`v1` image, but was originally published under the `:latest` tag. You can use
either `v1` or `latest` - they are the same version.  In future, we may
deprecate the `latest` tag and require users to update their `project.yaml` to
use `v1` instead of `latest`.


## Update Policy

### R Package Versions

We do not plan to add anymore packages to the v1 image.

For the v2 image, the versions of R packages from CRAN tied to a CRAN date.
We can easily install any additional package from the same CRAN date.
Additional packages may be requested by creating an issue in the repo.

Occasionally, we will create a new major version of the image with all packages
updated to their latest version. We may also possibly remove old and uneeded
pacakges at this point.  A new major version is a chance to make backwards
incompatible changes, which is occasionally needed.

### Operating System Packages

We *do* update the underlying operating system packages on a regular basis, in
order to apply security updates to the base system. It is very unlikely that
this will break backwards compatibility, as these are a small set very
conservative set of updates to address security issues.

We also add additional operating system libraries on user request.
