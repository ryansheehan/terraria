#!/usr/bin/env bash

if [ -z "$WORLD_FILENAME" ]; then
    /terraria-server/TerrariaServer -world $@
else
    /terraria-server/TerrariaServer -world $CONFIGPATH/$WORLD_FILENAME $@
fi
