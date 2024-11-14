if (Sys.getenv("MAJOR_VERSION") == "v1") {
  install.packages("renv", destdir = "/cache")
  renv::init(bare = TRUE)
  renv::restore()
} else if (Sys.getenv("MAJOR_VERSION") == "v2") {
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
  renv::install("pak", destdir = "/cache", repos = c(CRAN = REPOS))
  options(renv.config.pak.enabled = TRUE)
  pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
  renv::init(bare = TRUE)
  renv::restore()
  # To obtain pak in the final set of installed packages we seem to need to reinstall
  renv::install("pak", destdir = "/cache")
  renv::snapshot(type = "all")
  if (!PACKAGE %in% c("", "pak")) {
    renv::install(PACKAGE, destdir = "/cache")
    renv::snapshot(type = "all")
  }
}
