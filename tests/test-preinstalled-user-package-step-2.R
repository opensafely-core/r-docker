# User library directory should already exist, hence .libPaths() is amended
stopifnot(.libPaths()[1] == "/workspace/.local-packages/r/v2")
# Load the pre-installed package from previous R session which is now in repo
library(tmsens)
print("Step 2: Loading a pre-installed user package in a different R session test passed.")
