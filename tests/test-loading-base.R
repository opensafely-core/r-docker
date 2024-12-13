options(warn = -1)
basepkgs <- c("base", "compiler", "datasets", "grDevices", "graphics", "grid", "methods", "parallel", "splines", "stats", "stats4", "tcltk", "tools", "utils")

for (i in 1:length(basepkgs)) {
  suppressMessages({
    if (!library(basepkgs[i], logical.return = TRUE, character.only = TRUE)) {
      stop(paste("Package", basepkgs[i], "failed to load, please investigate"))
    }
  })
}

print("All base R packages successfully loaded.")
