#!/bin/sh

echo "\nBootstrap:\nworld_file_name=$WORLD_FILENAME\nconfigpath=$CONFIGPATH\nlogpath=$LOGPATH\n"
echo "Copying plugins..."
cp -Rfv /plugins/* ./ServerPlugins

STORAGETYPE=$(cat $CONFIGPATH/config.json | jq -r '.StorageType')
if [ $STORAGETYPE = "mysql" ]; then
  DATABASE_SERVER=$(cat $CONFIGPATH/config.json | jq -r '.MySqlHost' | cut -f1 -d':')
  DATABASE_PORT=$(cat $CONFIGPATH/config.json | jq -r '.MySqlHost' | cut -f2 -d':')
  DATABASE_USER_NAME=$(cat $CONFIGPATH/config.json | jq -r '.MySqlUsername')
  DATABASE_USER_PASSWORD=$(cat $CONFIGPATH/config.json | jq -r '.MySqlPassword')
  echo "Waiting for the database server."
  while ! mysql -h$DATABASE_SERVER -P$DATABASE_PORT -u$DATABASE_USER_NAME -p$DATABASE_USER_PASSWORD  -e ";" ; do
    sleep 0.1;
  done
fi

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
  mono --server --gc=sgen -O=all TerrariaServer.exe -configpath "$CONFIGPATH" -logpath "$LOGPATH" -config "$CONFIG" "$@"
else
  echo "Environment WORLD_FILENAME specified"
  if [ -f "$WORLD_PATH" ]; then
    echo "Loading to world $WORLD_FILENAME..."
    mono --server --gc=sgen -O=all TerrariaServer.exe -configpath "$CONFIGPATH" -logpath "$LOGPATH" -config "$CONFIG" -world "$WORLD_PATH" "$@"
  else
    echo "Unable to locate $WORLD_PATH.\nPlease make sure your world file is volumed into docker: -v <path_to_world_file>:/root/.local/share/Terraria/Worlds"
    exit 1
  fi
fi
