#!/bin/bash

# On Linux set rstudio user id to same as id of host if rstudio user id not already the same
if [ "$HOSTPLATFORM" = "linux" -a "$(id -u rstudio)" != "$HOSTUID" ]; then
  usermod -u $HOSTUID rstudio
fi

# Check for 1 .Rproj file
if [ $(find /workspace -type f -name "*.Rproj" | wc -w) -eq 1 ]; then

  # Copy in Git user.name and user.email from copied local-gitconfig from additionally mounted volume
  if test -f /home/rstudio/local-gitconfig; then
    grep -e "\[user\]" -e "name = *" -e "email = *" /home/rstudio/local-gitconfig >> /home/rstudio/.gitconfig
  fi

  # Avoid Git error: fatal detected dubious ownership of repository if using Git in container
  # Without this the Git pane fails to open when RStudio project opened
  echo -e "[safe]\n\tdirectory = \"*\"" >> /home/rstudio/.gitconfig

  # Open RStudio project on opening RStudio Server session using an rstudio hook in .Rprofile
  cat /home/rstudio/rstudio-rprofile.R >> /home/rstudio/.Rprofile
fi

# Set RStudio session user settings
#  - Enable autosave on blur - auto save when editor loses focus
#  - Enable autosave on idle - commit changes to documents on idle
#  - Set file line endings as crlf if docker run from Windows
if [ "$HOSTPLATFORM" = "win32" ] || [ "$HOSTPLATFORM" = "windows" ]; then
  echo -e "{\n\t\"line_ending_conversion\": \"windows\",\n\t\"auto_save_on_blur\": true,\n\t\"auto_save_on_idle\": \"commit\"\n}" > /etc/rstudio/rstudio-prefs.json
else
  echo -e "{\n\t\"auto_save_on_blur\": true,\n\t\"auto_save_on_idle\": \"commit\"\n}" > /etc/rstudio/rstudio-prefs.json  
fi

# Start RStudio Server session in foreground
# Hence don't use `rstudio-server start` which runs in background
# By redirecting stdout and stderrr to rstudio.log file, the TTY informational messages are not shown
# There are also log files in /var/log/rstudio/rstudio-server/rserver.log and
# /home/rstudio/.local/share/rstudio/log/rsession-rstudio.log
touch /var/log/rstudio/rstudio-server/rserver.log
exec &> >(tail -F /var/log/rstudio/rstudio-server/rserver.log)
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0
