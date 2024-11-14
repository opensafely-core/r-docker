PACKAGE <- Sys.getenv("PACKAGE")

if (Sys.getenv("MAJOR_VERSION") == "v1") {
  renv::activate()
  renv::install(PACKAGE)
  renv::snapshot(type = "all")
} else if (Sys.getenv("MAJOR_VERSION") == "v2") {
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

  renv::activate()
  renv::install(PACKAGE, repos = REPOS)
  renv::snapshot(type = "all")
}
