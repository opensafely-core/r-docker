REPOS <- Sys.getenv("REPOS")
CRAN_DATE <- Sys.getenv("CRAN_DATE")

options(HTTPUserAgent = sprintf(
  "R/%s R (%s)", getRversion(),
  paste(
    getRversion(),
    R.version["platform"],
    R.version["arch"],
    R.version["os"]
  )
))

install.packages("renv", destdir = "/cache", repos = c(CRAN = REPOS))
renv::init(bare = TRUE)
renv::snapshot(type = "all")
renv::install("pak", destdir = "/cache", repos = c(CRAN = REPOS))
pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
options(renv.config.pak.enabled = TRUE)
pkgs <- read.csv("packages.csv")$Package
pkgs <- pkgs[!pkgs %in% c("renv", "dummies", "maptools", "mnlogit", "rgdal", "rgeos")]
renv::install(pkgs, destdir = "/cache")
renv::install("sjPlot", destdir = "/cache")
renv::snapshot(type = "all")
