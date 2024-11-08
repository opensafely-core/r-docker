PACKAGE <- Sys.getenv("PACKAGE")

if (Sys.getenv("MAJOR_VERSION") == "v1") {
  renv::activate()
  renv::install(PACKAGE)
  renv::snapshot(type = "all")
} else if (Sys.getenv("MAJOR_VERSION") == "v2") {
  CRAN_DATE <- Sys.getenv("CRAN_DATE")

  print(Sys.getenv())
  print(.libPaths())
  print(Sys.getenv("MAJOR_VERSION"))
  print(CRAN_DATE)
  print(PACKAGE)
  print(nrow(installed.packages()))
  print(getwd())
  print(list.files())
  print("/cache/binary")
  print(list.files("/cache/binary"))
  
  print("/cache/binary/linux-ubuntu-noble/R-4.4/x86_64-pc-linux-gnu/repsository")
  print(list.files("/cache/binary/linux-ubuntu-noble/R-4.4/x86_64-pc-linux-gnu/repository/pak"))

  print("/cache/cache/v5/linux-ubuntu-noble/R-4.4/x86_64-pc-linux-gnu/pak/0.8.0")
  print(list.files("/cache/cache/v5/linux-ubuntu-noble/R-4.4/x86_64-pc-linux-gnu/pak/0.8.0"))
  
  print("/renv/lib")
  print(list.files("/renv/lib"))
  
  print("/renv/lib/linux-ubuntu-noble/R-4.4/x86_64-pc-linux-gnu")
  print(list.files("/renv/lib/linux-ubuntu-noble/R-4.4/x86_64-pc-linux-gnu"))
  
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

  options(renv.config.pak.enabled = TRUE)
  pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
  renv::install(PACKAGE)
  renv::snapshot(type = "all")
}
