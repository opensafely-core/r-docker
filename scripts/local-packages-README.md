# .local-packages a directory for user installed libraries

This directory contains user installed libraries, for say use running OpenSAFELY code in a Codespace or locally.

## How to add and remove user installed R packages

The _.local-packages/r/v2_ directory contains user installed R packages to work in the `r:v2` and `rstudio:v2` images.

You can install additional packages by running

```r
install.packages("PACKAGENAME")
```

or by using the RStudio _Package_ pane _Install_ button.

Note that packages are installed from the same date from CRAN as the other packages in the `r:v2` image. This is to ensure user installed packages work with the other packages in the image (at the time of installation).

If you no longer require a package you can also

```r
remove.packages("PACKAGENAME")
```

as usual.
