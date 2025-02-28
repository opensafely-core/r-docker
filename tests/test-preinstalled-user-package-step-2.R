# User library directory should already exist, hence .libPaths() is amended
stopifnot(.libPaths()[1] == "/workspace/lib/v2")
# Load the pre-installed package from previous R session which is now in repo
library(tmsens)
# Uninstall package and delete user R library, so not to leave it in repo
detach(package:tmsens)
remove.packages("tmsens")
unlink("/workspace/lib", recursive = TRUE)
print("Step 2: Loading a pre-installed user package in a different R session test passed.")
