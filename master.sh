#!/usr/bin/env bash
docker build --platform linux/amd64 -t remlapmot/r-docker:r-v1-for-will .
# docker run --rm -it --platform linux/amd64 remlapmot/r-docker:r-v1-for-will
# docker push remlapmot/r-docker:r-v1-for-will
# docker tag remlapmot/r-docker:r-v1-for-will ghcr.io/opensafely-core/r:latest
 
docker build --platform linux/amd64 -t remlapmot/r-docker:rstudio-v1-for-will -f rstudio.Dockerfile .
# docker push remlapmot/r-docker:rstudio-v1-for-will
# docker tag remlapmot/r-docker:rstudio-v1-for-will ghcr.io/opensafely-core/rstudio:latest
