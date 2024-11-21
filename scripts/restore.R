REPOS <- Sys.getenv("REPOS")
CRAN_DATE <- Sys.getenv("CRAN_DATE")
PACKAGE <- Sys.getenv("PACKAGE")

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

install.packages("renv", repos = c(CRAN = REPOS), destdir = "/cache")
renv::init(bare = TRUE)
renv::install("pak", repos = c(CRAN = REPOS))
options(renv.config.pak.enabled = TRUE)
pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
renv::restore()
# To obtain pak in the final set of installed packages we seem to need to reinstall pak
renv::install("pak")

# Install additional package
if (!PACKAGE %in% c("", "pak")) {
  renv::install(PACKAGE)
}

renv::snapshot(type = "all")
