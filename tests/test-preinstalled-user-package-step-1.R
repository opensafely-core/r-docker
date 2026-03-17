# .libPaths() should not have been amended yet
local_pkg_dir <- paste0("/workspace/.local-packages/r/", Sys.getenv("MAJOR_VERSION"))
stopifnot(.libPaths()[1] != local_pkg_dir)
# install package to user library in repo
install.packages("tmsens")
# .libPaths() should have been amended
stopifnot(.libPaths()[1] == local_pkg_dir)
print("Step 1: installing user package and amending .libPaths() paths test passed")
