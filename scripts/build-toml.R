REPOS <- Sys.getenv("REPOS")
CRAN_DATE <- Sys.getenv("CRAN_DATE")

# Set HTTPUserAgent so that PPPM serves binary R packages for Linux
options(HTTPUserAgent = sprintf(
  "R/%s R (%s)", getRversion(),
  paste(
    getRversion(),
    R.version["platform"],
    R.version["arch"],
    R.version["os"]
  )
))

install.packages(c("RcppTOML", "pak"), repos = c(CRAN = REPOS), destdir = "/cache")

# Read in packages.toml
input <- RcppTOML::parseTOML("/tmp/packages.toml")
# unload Rcpp and RcppTOML (as they are loaded [but not attached] by line above)
unloadNamespace("RcppTOML")
unloadNamespace("Rcpp")
# Delete RcppTOML as we don't use it again
remove.packages("RcppTOML")

# Set pak to use PPPM CRAN snapshot repository
pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
# Disable pak updating system requirements
options(pkg.sysreqs = FALSE)
# update metadata database everytime
options(pkg.metadata_update_after = as.difftime(1, units = "secs"))

# Obtain package names
pkgs <- unique(na.omit(unlist(sapply(input, "[", "packages"))))

# Obtain non-CRAN CRAN-like repositories, and add them to pak
repos <- unique(na.omit(unlist(sapply(input, "[", "repos"))))
repos <- repos[repos != ""]
nrepos <- length(repos)
names(repos) <- LETTERS[1:nrepos]
pak::repo_add(.list = repos)

# Create pkg.lock file
pak::lockfile_create(pkgs, lockfile = "/pkg.lock")

# Install the packages based upon the lockfile
pak::lockfile_install("/pkg.lock")

# pak is not required in the final image
remove.packages("pak")
