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

# Remove any duplicates from package vector
pkgs <- unique(input[[1]])
# Install the packages from PPPM on the CRAN_DATE and from the additional CRAN-like repositories
pak::pkg_install(pkgs)
