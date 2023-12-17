#!/bin/bash

echo "\nBootstrap:\nworld_file_name=$WORLD_FILENAME\nconfigpath=$CONFIGPATH\nlogpath=$LOGPATH\n"
echo "Copying plugins..."
cp -Rfv /plugins/* ./ServerPlugins

if [ $(jq -r '.Settings.StorageType' $CONFIGPATH/config.json) = "mysql" ]; then
  DATABASE_SERVER=$(jq -r '.Settings.MySqlHost' $CONFIGPATH/config.json | cut -f1 -d':')
  DATABASE_PORT=$(jq -r '.Settings.MySqlHost' $CONFIGPATH/config.json | cut -f2 -d':')
  DATABASE_USER_NAME=$(jq -r '.Settings.MySqlUsername' $CONFIGPATH/config.json)
  DATABASE_USER_PASSWORD=$(jq -r '.Settings.MySqlPassword' $CONFIGPATH/config.json)
  echo "Waiting for the database server."
  while ! mysql -h$DATABASE_SERVER -P$DATABASE_PORT -u$DATABASE_USER_NAME -p$DATABASE_USER_PASSWORD  -e ";" ; do
    sleep 0.1;
  done
fi

WORLD_PATH="/root/.local/share/Terraria/Worlds/$WORLD_FILENAME"

autocreate_flag=false
for arg in "$@"; do
    if [ "$arg" = "-autocreate" ]; then
        autocreate_flag=true
        break
    fi
done


if [ -z "$WORLD_FILENAME" ]; then
  echo "No world file specified in environment WORLD_FILENAME."
  if [ -z "$@" ]; then 
    echo "Running server setup..."
  else
    echo "Running server with command flags: $@"
  fi
  ./TShock.Server -configpath "$CONFIGPATH" -logpath "$LOGPATH" "$@" 
else
  echo "Environment WORLD_FILENAME specified"
  if [ -f "$WORLD_PATH" ] || [ "$autocreate_flag" = true ]; then
      echo "Loading to world $WORLD_FILENAME..."
      ./TShock.Server -configpath "$CONFIGPATH" -logpath "$LOGPATH" -world "$WORLD_PATH" "$@"
  else
      echo "Unable to locate $WORLD_PATH and -autocreate flag is not set."
      echo "Please make sure your world file is volumed into docker: -v <path_to_world_file>:/root/.local/share/Terraria/Worlds"
      echo "Alternatively, use the -autocreate flag to create a new world."
      exit 1
  fi
fi
