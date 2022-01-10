#!/bin/bash

echo "Bootstrap:"
echo "world_file_name=$WORLD_FILENAME"
echo "logpath=$LOGPATH"

WORLD_PATH="/root/.local/share/Terraria/Worlds/$WORLD_FILENAME"
if [ ! -f "/config/serverconfig.txt" ]; then
    echo "Server configuration not found, running with default server configuration."
    echo "Please ensure your desired serverconfig.txt file is volumed into docker: -v <path_to_config_file>:/config"
    cp ./serverconfig-default.txt /config/serverconfig.txt
fi

if [ -z "$WORLD_FILENAME" ]; then
  echo "No world file specified in environment WORLD_FILENAME."
  if [ -z "$@" ]; then
    echo "Running server setup..."
  else
    echo "Running server with command flags: $@"
  fi
  mono TerrariaServer.exe -config "/config/serverconfig.txt" -logpath "$LOGPATH" "$@"
else
  echo "Environment WORLD_FILENAME specified"
  if [ -f "$WORLD_PATH" ]; then
    echo "Loading to world $WORLD_FILENAME..."
    mono TerrariaServer.exe -config "/config/serverconfig.txt" -logpath "$LOGPATH" "$@" -world "$WORLD_PATH" "$@"
  else
    echo "Unable to locate $WORLD_PATH."
    echo "Please make sure your world file is volumed into docker: -v <path_to_world_file>:/root/.local/share/Terraria/Worlds"
    exit 1
  fi
fi

