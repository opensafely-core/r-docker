#!/bin/bash

# Check .gitignore for some entries, add them if not present
for item in .local .config .Rhistory .Rproj.user .Rproj.user/ .DS_Store ;
do
  if ! grep -q $item /home/rstudio/.gitignore; then
    echo $item >> /home/rstudio/.gitignore
  fi
done

# Check for an .Rproj file - if exists open project on RStudio Server session start
if [ -f *.Rproj ] ; then
  file=$(ls *.Rproj)
  echo "setHook(\"studio.sessionInit\", function(newSession) { if (newSession && is.null(rstudioapi::getActiveProject())) rstudioapi::openProject(\"$file\") }, action = \"append\")" | sudo tee -a /usr/lib/R/etc/Rprofile.site > /dev/null

  # Avoid Git error fatal detected dubious ownership of repository if using Git in container
  # Without this the Git pane fails to open when RStudio project opened
  echo "[safe]" >> .gitconfig
  echo "	directory = /home/rstudio" >> .gitconfig
fi 

# Start RStudio Server session
rstudio-server start
# Ensure that the docker container does not exit
sleep infinity
