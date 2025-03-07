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
if (dir.exists('/workspace/.local-packages/r/v2'))
  .libPaths(c('/workspace/.local-packages/r/v2', .libPaths()))
install.packages <- function(...) {
  if (!dir.exists("/workspace/.local-packages/r/v2")) {
    dir.create("/workspace/.local-packages/r/v2", recursive = TRUE)
    .libPaths(c("/workspace/.local-packages/r/v2", .libPaths()))
    file.create("/workspace/.local-packages/.gitignore")
  }
  if (!file.exists("/workspace/.local-packages/README.md")) {
      file.copy("/usr/local-packages-README.md", "/workspace/.local-packages/README.md")
  }
  utils::install.packages(...)
}
