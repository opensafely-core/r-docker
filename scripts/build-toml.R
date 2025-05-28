REPOS <- Sys.getenv("REPOS")
CRAN_DATE <- Sys.getenv("CRAN_DATE")

install.packages(
  "pak",
  repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s",
    .Platform$pkgType,
    R.Version()$os,
    R.Version()$arch
  ),
  destdir = "/cache"
)

# Set pak to use PPPM CRAN snapshot repository
pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
# Disable pak updating system requirements
options(pkg.sysreqs = FALSE)
# update metadata database everytime
options(pkg.metadata_update_after = as.difftime(1, units = "secs"))
# disable updating existing system requirements on CI
options(pkg.sysreqs_update = FALSE)

# use pak to manage RcppTOML
pak::pkg_install("RcppTOML")

# Read in packages.toml
input <- RcppTOML::parseTOML("/tmp/packages.toml")
# unload Rcpp and RcppTOML (as they are loaded [but not attached] by line above)
unloadNamespace("RcppTOML")
unloadNamespace("Rcpp")
# Delete RcppTOML as we don't use it again
pak::pkg_remove("RcppTOML")

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
