#!/bin/bash

# Check .gitignore for some entries, add them if not present
for item in .local .config;
do
  if ! grep -q $item /workspace/.gitignore; then
    echo $item >> /workspace/.gitignore
  fi
done

# Check for 1 .Rproj file
if [ $(find /workspace -type f -name "*.Rproj" | wc -w) -eq 1 ]; then
  # Avoid creating setting in .gitconfig if already specified
  if ! grep -e "\[safe\]" -e "\tdirectory = \"\*\"" /workspace/.gitconfig; then 
    # Avoid Git error fatal detected dubious ownership of repository if using Git in container
    # Without this the Git pane fails to open when RStudio project opened
    echo -e "[safe]\n\tdirectory = \"*\"" >> /workspace/.gitconfig
  fi
fi

# Start RStudio Server session
# rstudio-server start
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0

# Ensure that the docker container does not exit
# sleep infinity
