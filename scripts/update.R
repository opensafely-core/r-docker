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

file.rename(from = "renv.lock", to = "renv.lock.bak")
install.packages("renv", destdir = "/cache", repos = c(CRAN = REPOS))
renv::init(bare = TRUE)
renv::snapshot(type = "all")
renv::install("pak", destdir = "/cache", repos = c(CRAN = REPOS))
pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
options(renv.config.pak.enabled = TRUE)
renv::install("jsonlite", destdir = "/cache")
pkgs <- names(jsonlite::read_json("renv.lock")$Packages)
pkgs <- pkgs[!pkgs %in% c("renv", "dummies", "maptools", "mnlogit", "rgdal", "rgeos", "jsonlite")]
renv::install(pkgs, destdir = "/cache")
renv::install("sjPlot", destdir = "/cache")
renv::snapshot(type = "all")
