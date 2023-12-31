#!/bin/bash

if [ $(jq -r '.Settings.StorageType' $CONFIG_PATH/config.json) = "mysql" ]; then
  DATABASE_SERVER=$(jq -r '.Settings.MySqlHost' $CONFIG_PATH/config.json | cut -f1 -d':')
  DATABASE_PORT=$(jq -r '.Settings.MySqlHost' $CONFIG_PATH/config.json | cut -f2 -d':')
  DATABASE_USER_NAME=$(jq -r '.Settings.MySqlUsername' $CONFIG_PATH/config.json)
  DATABASE_USER_PASSWORD=$(jq -r '.Settings.MySqlPassword' $CONFIG_PATH/config.json)
  echo "Waiting for the database server."
  while ! mysql -h$DATABASE_SERVER -P$DATABASE_PORT -u$DATABASE_USER_NAME -p$DATABASE_USER_PASSWORD  -e ";" ; do
    sleep 0.1;
  done
fi

if [ -z "$(ls -A /tshock/ServerPlugins)" ]; then
  echo "Copying plugins..."
  cp /plugins/* /tshock/ServerPlugins
fi

echo "./TShock.Server -config \"$CONFIG_PATH/serverconfig.txt\" -configpath \"$CONFIG_PATH\" -logpath \"$LOG_PATH\" -worldpath /root/.local/share/Terraria/Worlds/ \"$@\""
./TShock.Server -config "$CONFIG_PATH/serverconfig.txt" -configpath "$CONFIG_PATH" -logpath "$LOG_PATH" -worldpath /root/.local/share/Terraria/Worlds/ "$@"