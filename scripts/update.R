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
install.packages("renv", repos = c(CRAN = REPOS), destdir = "/cache")
renv::init(bare = TRUE)
renv::install(c("jsonlite", "pak"), repos = c(CRAN = REPOS))
pak::repo_add(CRAN = paste0("RSPM@", CRAN_DATE))
options(renv.config.pak.enabled = TRUE)
pkgs <- names(jsonlite::read_json("renv.lock.bak")$Packages)

# Remove R packages that are no longer on CRAN
pkgs <- pkgs[!pkgs %in% c("renv", "dummies", "maptools", "mnlogit", "rgdal", "rgeos", "jsonlite")]

# Add sjPlot - requested in issue #160
pkgs <- c(pkgs, "sjPlot")

renv::install(pkgs)
renv::snapshot(type = "all")
