#!/bin/bash

# Check .gitignore for some entries, add them if not present
for item in .local .config .Rhistory .Rproj.user .Rproj.user/ .DS_Store ;
do
  if ! grep -q $item /home/rstudio/.gitignore; then
    echo $item >> /home/rstudio/.gitignore
  fi
done

# Start RStudio Server session
rstudio-server start
# Ensure that the docker container does not exit
sleep infinity
