setHook("rstudio.sessionInit", function(newSession) {
  if (newSession && is.null(rstudioapi::getActiveProject())) {
    rstudioapi::openProject(paste0("/workspace/", list.files(pattern = "Rproj")))
  }
}, action = "append")
