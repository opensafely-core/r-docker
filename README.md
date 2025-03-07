# OpenSAFELY R Runtime Image

This repo manages the Docker image for the OpenSAFELY Python runtime. These
images are based on a base Ubuntu LTS version, and come pre-installed with
a set of standard scientific python packages.

The current latest version is `v2`, and you should use that unless you have
a specific reason. You can use it in your `project.yaml` like so:

```
actions:
  my_action:
    run: python:v2 my_script.py ...
```

## Version List

Current available versions, in reverse chronological order:

 - v2: Ubuntu 22.04 and Python 3.10 - [full package list](v2/packages.md)
 - v1: Ubuntu 20.04 and Python 3.8 - [full package list](v1/packages.md)

### Legacy version: `latest`

Initially, OpenSAFELY only had one version of the python image. This is the
`v1` image, but was originally published under the `:latest` tag. You can use
either `v1` or `latest` - they are the same version.  In future, we may
deprecate the `latest` tag and require users to update their `project.yaml` to
use `v1` instead of `latest`.


## Update Policy

### Python Package Versions

For each version of the python image, we do *not* upgade the python packages
from their initially installed version. This is done in order to backwards
compatiblity and thus ensure reproduciblity. We do [add new packages on user
request](https://github.com/opensafely-core/python-dockerissues/new?template=new-package.md),
as such a change will not break backwards incompatibilty.

Occasionally, we will create a new major version of the image with all packages
updated to their latest version. We may also possibly remove old and uneeded
pacakges at this point.  A new major version is chance to make backwards
incompatible changes, which is occasionally needed.

Once this new version of the image is intially released, its set of package
versions will be frozen and no longer updatable.

### Operating System Packages

We *do* update the underlying operating system packages on a regular basis, in
order to apply security updates to the base system. It is very unlikely that
this will break backwards compatibility, as these are a small set very
conservative set of updates to address security issues.

We also add additional operating system libraries on user request.
