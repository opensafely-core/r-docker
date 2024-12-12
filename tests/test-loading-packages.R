options(warn = -1)
Sys.setenv('_R_S3_METHOD_REGISTRATION_NOTE_OVERWRITES_'=0)
pkgs <- installed.packages()[, 1]
pkgs <- pkgs[!pkgs %in% c("base", "compiler", "datasets", "grDevices", "graphics", "grid", "methods", "parallel", "splines", "stats", "stats4", "tcltk", "tools", "utils")]
pkgs <- unname(pkgs)
npkgs <- length(pkgs)

for (i in 1:npkgs) {
    package <- pkgs[i]
    suppressMessages({
    if (!library(package, logical.return = TRUE, character.only = TRUE)) {
      stop(paste("Package", package, "failed to load, please investigate"))
    }
    dtch <- paste0("package:", package)
    detach(dtch, force = TRUE, unload = TRUE, character.only = TRUE)
    })
}
