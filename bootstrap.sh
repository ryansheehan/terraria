#!/bin/sh

echo "\nBootstrap:\nconfigpath=$CONFIGPATH\nworldpath=$WORLDPATH\nlogpath=$LOGPATH\n"
echo "Copying plugins..."
cp -Rfv /plugins/* ./ServerPlugins

mono --server --gc=sgen -O=all TerrariaServer.exe -configPath "$CONFIGPATH" -worldpath "$WORLDPATH" -logpath "$LOGPATH" -world "$WORLD" "$@" 
