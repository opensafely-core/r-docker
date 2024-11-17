FROM remlapmot/r-docker:r-v1-for-will AS r-image
FROM ghcr.io/opensafely-core/rstudio:latest
COPY --from=r-image /usr/local/lib/R/site-library/dagitty /renv/lib/R-4.0/x86_64-pc-linux-gnu/dagitty
COPY --from=r-image /usr/local/lib/R/site-library/dd4d /renv/lib/R-4.0/x86_64-pc-linux-gnu/dd4d
