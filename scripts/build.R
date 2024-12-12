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

install.packages("pak", repos = c(CRAN = REPOS), destdir = "/cache")
pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
options(pkg.sysreqs = FALSE)

# Read in input list
input <- utils::read.csv("/tmp/packages.csv", header = TRUE)
# Obtain list of non-CRAN CRAN-like repositories, and add them to pak
repos <- unique(input[[2]])
repos <- repos[repos != ""]
nrepos <- length(repos)
names(repos) <- LETTERS[1:nrepos]
pak::repo_add(.list = repos)

# Include pak in packages list, and remove any duplicates
pkgs <- unique(c("pak", input[[1]]))

# Create pkg.lock file
pak::lockfile_create(pkgs, lockfile = "/pkg.lock")

# Install the packages based upon the lockfile
pak::lockfile_install("/pkg.lock")
