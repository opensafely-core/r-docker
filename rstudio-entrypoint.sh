#!/bin/bash

# Check .gitignore for some entries, add them if not present
for item in .local .config .Rhistory .Rproj.user .Rproj.user/ .DS_Store ;
do
  if ! grep -q $item /home/rstudio/.gitignore; then
    echo $item >> /home/rstudio/.gitignore
  fi
done

# Check for 1 .Rproj file
if [ $(find /home/rstudio -type f -name "*.Rproj" | wc -w) -eq 1 ] ; then
  # Avoid Git error fatal detected dubious ownership of repository if using Git in container
  # Without this the Git pane fails to open when RStudio project opened
  echo "[safe]" >> /home/rstudio/.gitconfig
  echo "	directory = \"*\"" >> /home/rstudio/.gitconfig

  # Rstudio hook to open project on startup if 1 .Rproj file exists
  echo "if (length(list.files(pattern = \"Rproj\")) == 1L) setHook(\"rstudio.sessionInit\", function(newSession) { if (newSession && is.null(rstudioapi::getActiveProject())) rstudioapi::openProject(list.files(pattern = \"Rproj\")) }, action = \"append\")" >> /home/rstudio/.Rprofile
fi

# Start RStudio Server session
rstudio-server start

# Ensure that the docker container does not exit
sleep infinity
