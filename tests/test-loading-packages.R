options(warn = -1)
Sys.setenv('_R_S3_METHOD_REGISTRATION_NOTE_OVERWRITES_'=0)
pkgs <- installed.packages()[, 1]
pkgs <- pkgs[!pkgs %in% c("base", "compiler", "datasets", "grDevices", "graphics", "grid", "methods", "parallel", "splines", "stats", "stats4", "tcltk", "tools", "utils")]
pkgs <- unname(pkgs)
npkgs <- length(pkgs)

for (i in 1:npkgs) {
    package <- pkgs[i]
    tryCatch({
    suppressMessages(library(package, character.only = TRUE))
    dtch <- paste0("package:", package)
    detach(dtch, force = TRUE, unload = TRUE, character.only = TRUE)
    }, error = function(e) {
      stop(paste0("Package ", package, " failed to load: ", conditionMessage(e)))
    })
}

print("All non-base R packages successfully loaded and unloaded.")
