options(warn = -1)
basepkgs <- c("base", "compiler", "datasets", "grDevices", "graphics", "grid", "methods", "parallel", "splines", "stats", "stats4", "tcltk", "tools", "utils")

for (i in seq_along(basepkgs)) {
  suppressMessages({
    if (!library(basepkgs[i], logical.return = TRUE, character.only = TRUE)) {
      stop(paste("Package", basepkgs[i], "failed to load, please investigate"))
    }
  })
}

print("All base R packages successfully loaded.")

# Note that the loading of the recommended packages is tested with the pkg.lock file packages because they are listed in there.
