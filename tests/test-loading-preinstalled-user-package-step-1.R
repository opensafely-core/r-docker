# .libPaths() should not have been amended yet
stopifnot(.libPaths()[1] != "/workspace/r-v2-library")
# install package to user library in repo
install.packages("tmsens")
# .libPaths() should have been amended
stopifnot(.libPaths()[1] == "/workspace/r-v2-library")
print("Step 1: installing user package and amending .libPaths() paths test passed")
