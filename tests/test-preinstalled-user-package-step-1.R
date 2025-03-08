# .libPaths() should not have been amended yet
stopifnot(.libPaths()[1] != "/workspace/.local-packages/r/v2")
# install package to user library in repo
install.packages("tmsens")
# .libPaths() should have been amended
stopifnot(.libPaths()[1] == "/workspace/.local-packages/r/v2")
print("Step 1: installing user package and amending .libPaths() paths test passed")
