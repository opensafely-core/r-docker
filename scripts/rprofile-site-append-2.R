# If the local package directory exists set as first entry of R's library path
# This is so that install.packages() and remove.packages() will use this directory by default.
.local_pkg_dir <- paste0('/workspace/.local-packages/r/', Sys.getenv("MAJOR_VERSION"))
if (dir.exists(.local_pkg_dir))
  .libPaths(c(.local_pkg_dir, .libPaths()))

# Monkey patch install.packages to create local package directory if it doesn't exist and
# create a .gitignore file within in and copy in the README.md.
# In R ... passes function arguments through to a subsequent call.
install.packages <- function(...) {
  local_pkg_dir <- paste0("/workspace/.local-packages/r/", Sys.getenv("MAJOR_VERSION"))
  if (!dir.exists(local_pkg_dir)) {
    dir.create(local_pkg_dir, recursive = TRUE)
    .libPaths(c(local_pkg_dir, .libPaths()))
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
