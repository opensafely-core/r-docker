# If the local package directory exists set as first entry of R's library path
# This is so that install.packages() and remove.packages() will use this directory by default.
if (dir.exists('/workspace/.local-packages/r/v2'))
  .libPaths(c('/workspace/.local-packages/r/v2', .libPaths()))

# Monkey patch install.packages to create local package directory if it doesn't exist and
# create a .gitignore file within in and copy in the README.md.
# In R ... passes function arguments through to a subsequent call.
install.packages <- function(...) {
  if (!dir.exists("/workspace/.local-packages/r/v2")) {
    dir.create("/workspace/.local-packages/r/v2", recursive = TRUE)
    .libPaths(c("/workspace/.local-packages/r/v2", .libPaths()))
    # create .gitignore file
    file.create("/workspace/.local-packages/.gitignore")
    fileconn <- file("/workspace/.local-packages/.gitignore")
    writeLines("*", fileconn)
    close(fileconn)
  }
  if (!file.exists("/workspace/.local-packages/README.md")) {
      file.copy("/usr/local-packages-README.md", "/workspace/.local-packages/README.md")
  }
  utils::install.packages(...)
}
