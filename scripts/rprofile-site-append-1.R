# Set the repository to download R packages from to be the PPPM CRAN snapshot at the chosen date
# Set HTTPUserAgent so that PPPM serves binary R packages for Linux in an R terminal session
# Note that RStudio (and rstudio-server) set this by default
options(
  repos = c(CRAN = Sys.getenv("REPOS")),
  HTTPUserAgent = sprintf(
    'R/%s R (%s)',
    getRversion(),
    paste(
      getRversion(),
      R.version['platform'],
      R.version['arch'],
      R.version['os']
    )
  )
)
