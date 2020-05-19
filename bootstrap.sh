#!/bin/sh

configpath="/world"
worldpath="/world"
logpath="/tshock/logs"

while :; do
  case $1 in
    -configpath) # check for confipath flag
      publishContainer=$2
      shift
      shift
      ;;
    -worldpath) # check for confipath flag
      worldpath=$2
      shift
      shift
      ;;
    -logpath) # check for confipath flag
      logpath=$2
      shift
      shift
      ;;
    --) # End of all options
      shift
      break
      ;;
    *) # no more options break out of loop
      break
  esac
done

echo "\nBootstrap Args:\nconfigpath=$configpath\nworldpath=$worldpath\nlogpath=$logpath\nrest=$@\n"

cp ./TShockAPI.dll ./ServerPlugins

mono --server --gc=sgen -O=all TerrariaServer.exe -configPath "$configpath" -worldpath "$worldpath" -logpath "$logpath" "$@" 