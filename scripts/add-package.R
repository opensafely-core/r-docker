PACKAGE <- Sys.getenv("PACKAGE")
REPOS <- Sys.getenv("REPOS")


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

renv::install(PACKAGE, repos = REPOS)
renv::snapshot(type = "all")
