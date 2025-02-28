# Test settings
print("Library paths settings checks")

print("repos setting:")
print(getOption("repos"))
stopifnot(getOption("repos") == Sys.getenv("REPOS"))

print("HTTPUserAgent setting:")
print(getOption('HTTPUserAgent'))
stopifnot(getOption("HTTPUserAgent") == sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version['platform'], R.version['arch'], R.version['os'])))

print("Library paths")
print(.libPaths())
stopifnot(.libPaths()[1] == "/workspace/r-v2-library")

print("Library settings tests passed.")

# Test installing then removing a package to /workspace/r-v2-library
# I have chosen the tmsens package because it has no dependencies
install.packages("tmsens")
print("Installation test passed.")
# Test loading that package
library(tmsens)
print("Loading user installed package test passed.")
# Remove the test package
detach(package:tmsens)
list.files("/workspace/r-v2-library/tmsens")
remove.packages("tmsens")
print(list.files('workspace/r-v2-library'))
print("Removing user installed package test passed.")

print("Installing and removing a user installed package tests passed.")
