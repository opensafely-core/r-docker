# OpenSAFELY R and RStudio Runtime Images

This repo manages the Docker image for the OpenSAFELY R runtime and rstudio-server. These
images are based on a base Ubuntu LTS version, and come pre-installed with
a set of standard R packages.

The current latest version is `v2`, and you should use that unless you have
a specific reason. You can use it in your `project.yaml` like so:

```
actions:
  my_action:
    run: r:v2 analysis/my_script.R
```

The rstudio images are designed for use with `opensafely launch`. For example, to launch an rstudio-server session (i.e., RStudio running in a browser window) run the following in a Terminal from your research repository.

```sh
opensafely launch rstudio:v2
```

## Version List

Current available versions for the r image, in reverse chronological order:

 - v2: Ubuntu 22.04 and R 4.4.3 - [full package list](v2/packages.md)
 - v1: Ubuntu 20.04 and R 4.0.5 - [full package list](v1/packages.md) - please note that v1 is deprecated, new projects should use r:v2.

Current available versions for the rstudio image, in reverse chronological order:

 - v2: rstudio-server running r:v2
 - v1: rstudio-server running r:v1

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
In the v2 image you can request packages that are not on CRAN.

Occasionally, we will create a new major version of the image with all packages
updated to their latest version. We may also possibly remove old and uneeded
pacakges at this point.  A new major version is a chance to make backwards
incompatible changes, which is occasionally needed.

### User installed R packages

Especially when working in say a Codespace using the rstudio:v2 image you may wish to add some packages for your post release analysis.
The v2 images are configured to allow you to install your own packages, which will be saved to a _.local-packages/r/v2_ directory in your research repository.
If the packages is on CRAN, to do this simply run the following.

```r
install.packages("PACKAGENAME")
```

You may also install packages from a remote repository, for example if the package is on GitHub only, to do this install the remotes package first as follows.

```r
install.packages("remotes")
remotes::install_github("USERNAME/REPONAME")
```

Please note that user installed packages are temporary.
They are not saved into your research repository, nor are they saved in the Docker image.
You will need to reinstall user installed packages each time you create a new Codespace, or if you setup your repository on a different computer.

### Operating System Packages

We *do* update the underlying operating system packages on a regular basis, in
order to apply security updates to the base system. It is very unlikely that
this will break backwards compatibility, as these are a small set very
conservative set of updates to address security issues.

We also add additional operating system libraries on user request.
