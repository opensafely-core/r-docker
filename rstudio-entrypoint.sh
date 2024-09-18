#!/bin/bash

# Check for 1 .Rproj file
if [ $(find /workspace -type f -name "*.Rproj" | wc -w) -eq 1 ]; then
  # Avoid Git error fatal detected dubious ownership of repository if using Git in container
  # Without this the Git pane fails to open when RStudio project opened
  echo -e "[safe]\n\tdirectory = \"*\"" >> /home/rstudio/.gitconfig

  # Open RStudio project on opening RStudio Server session
  echo 'setHook("rstudio.sessionInit", function(newSession) { if (newSession && is.null(rstudioapi::getActiveProject())) rstudioapi::openProject(paste0("/workspace/", list.files(pattern = "Rproj"))) }, action = "append")' >> /home/rstudio/.Rprofile
fi

# Start RStudio Server session in foreground
# Hence don't use `rstudio-server start` which runs in background
# and suppress messages about logging etc.
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0 > /dev/null 2>&1
