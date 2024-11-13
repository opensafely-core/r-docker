PACKAGE <- Sys.getenv("PACKAGE")

if (Sys.getenv("MAJOR_VERSION") == "v1") {
  renv::activate()
  renv::install(PACKAGE)
  renv::snapshot(type = "all")
} else if (Sys.getenv("MAJOR_VERSION") == "v2") {
  CRAN_DATE <- Sys.getenv("CRAN_DATE")
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

  install.packages("pak", repos = REPOS)
  options(renv.config.pak.enabled = TRUE)
  pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
  pak::pkg_install("renv")
  renv::activate(project = "/renv")
  renv::install(PACKAGE)
  renv::snapshot(type = "all", force = TRUE)
}
