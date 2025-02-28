# Test settings
stopifnot(options("repos") == Sys.getenv("REPOS"))
stopifnot(options("HTTPUserAgent") == sprintf('R/%s R (%s)', getRversion(), paste(getRversion(), R.version['platform'], R.version['arch'], R.version['os'])))
stopifnot(.libPaths[1] == "/workspace/r-v2-library")

# Test installing a package
# I have chosen tmsens because it has no dependencies
install.packages("tmsens")
# Test loading that package
library(tmsens)
# Remove the test package
remove.packages("tmsens")
