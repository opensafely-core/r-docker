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
if (dir.exists('/workspace/lib/v2'))
  .libPaths(c('/workspace/lib/v2', .libPaths()))
install.packages <- function(...) {
  if (!dir.exists("/workspace/lib/v2")) {
    dir.create("/workspace/lib/v2", recursive = TRUE)
    .libPaths(c("/workspace/lib/v2", .libPaths()))
  }
  utils::install.packages(...)
}
