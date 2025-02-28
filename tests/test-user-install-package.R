# Test settings
print("Library paths settings checks")

print("repos setting:")
print(getOption("repos"))
stopifnot(getOption("repos") == Sys.getenv("REPOS"))

print("HTTPUserAgent setting:")
print(getOption('HTTPUserAgent'))
stopifnot(
  getOption("HTTPUserAgent") ==
    sprintf(
      "R/%s R (%s)",
      getRversion(),
      paste(
        getRversion(),
        R.version["platform"],
        R.version["arch"],
        R.version["os"]
      )
    )
)

# Test installing then removing a package to /workspace/lib/v2
# I have chosen the tmsens package because it has no hard dependencies
# (i.e., no other packages get installed along with it)
install.packages("tmsens")
print("Installation test passed.")
# Test loading that package
library(tmsens)
print("Loading user installed package test passed.")
# Remove the test package
detach(package:tmsens)

print("Library paths")
stopifnot(.libPaths()[1] == "/workspace/lib/v2")

# Test adding a second package works
# (again bpbounds chosen because it also has no hard dependencies)
install.packages("bpbounds")
library(bpbounds)
print("Test installing a second package passed.")
detach(package:bpbounds)

# Clean up, i.e., remove packages and delete /workspace/lib/v2 directory
remove.packages(c("tmsens", "bpbounds"))
unlink("/workspace/lib", recursive = TRUE)
print("Removing user installed package test passed.")

print("Installing and removing a user installed package tests passed.")
