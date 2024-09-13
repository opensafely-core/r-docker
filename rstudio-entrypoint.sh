#!/bin/bash

# Check .gitignore for some entries, add them if not present
for item in .local .config;
do
  if ! grep -q $item /home/rstudio/.gitignore; then
    echo $item >> /home/rstudio/.gitignore
  fi
done

# Check for 1 .Rproj file
if [ $(find /home/rstudio -type f -name "*.Rproj" | wc -w) -eq 1 ] ; then
  # Avoid Git error fatal detected dubious ownership of repository if using Git in container
  # Without this the Git pane fails to open when RStudio project opened
  echo "[safe]\n	directory = \"*\"" >> /home/rstudio/.gitconfig
fi

# Start RStudio Server session
rstudio-server start

# Ensure that the docker container does not exit
sleep infinity
