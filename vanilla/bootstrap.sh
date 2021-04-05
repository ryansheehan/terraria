#!/usr/bin/env bash

if [ -z "$WORLD_FILENAME" ]; then
    /terraria-server/TerrariaServer $@
else
    /terraria-server/TerrariaServer -world $CONFIGPATH/$WORLD_FILENAME $@
fi
