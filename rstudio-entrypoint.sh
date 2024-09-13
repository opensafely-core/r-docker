#!/bin/bash

# Check .gitignore for some entries, add them if not present
for item in .local .config .Rhistory .Rproj.user .Rproj.user/ .DS_Store ;
do
  if ! grep -q $item /home/rstudio/.gitignore; then
    echo $item >> /home/rstudio/.gitignore
  fi
done

# Check for an .Rproj file - if exists open project on RStudio Server session start
# if [ -f *.Rproj ] ; then

#   # Rstudio hook to open project on startup
#   file=$(ls *.Rproj)
#   echo "setHook(\"rstudio.sessionInit\", function(newSession) { if (newSession && is.null(rstudioapi::getActiveProject())) rstudioapi::openProject(\"$file\") }, action = \"append\")" | sudo tee -a /usr/lib/R/etc/Rprofile.site
# fi

# Start RStudio Server session
rstudio-server start

# Avoid Git error fatal detected dubious ownership of repository if using Git in container
# Without this the Git pane fails to open when RStudio project opened
sudo -H -u rstudio bash -c 'git config --global --add safe.directory /home/rstudio'
# echo "[safe]" >> /home/rstudio/.gitconfig
# echo "	directory = /home/rstudio" >> /home/rstudio/.gitconfig


# Ensure that the docker container does not exit
sleep infinity
