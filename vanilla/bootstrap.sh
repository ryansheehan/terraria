#!/bin/bash

# explicitly set user to root
export USER=root

# create a tmux config: ctrl+c will detach instead of killing
echo "bind-key -n C-c detach" > /terraria-server/tmux.conf
# ensure session dies when the server exits
echo "set-option -g remain-on-exit off" >> /terraria-server/tmux.conf

# shutdown logic
cleanup() {
    echo "Received Shutdown Signal"
    echo "Cleaning buffer and sending 'exit'..."

    # send 'enter' first to clear garbage characters
    tmux send-keys -t terraria Enter
    sleep 1

    # send the clean 'exit' command
    tmux send-keys -t terraria "exit" Enter

    # wait for the server to close
    while tmux has-session -t terraria 2>/dev/null; do
        echo "Waiting for server to save and exit..."
        tmux capture-pane -pt terraria | tail -n 1
        sleep 2
    done

    echo "Server Saved and Closed Cleanly"
    exit 0
}

trap 'cleanup' TERM

echo "Bootstrap:"
echo "world_file_name=$WORLD_FILENAME"
echo "logpath=$LOGPATH"
echo "target_arch=$TARGETARCH"

EXECUTABLE="./TerrariaServer"
if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ]; then
    EXECUTABLE="mono ./TerrariaServer.exe"
fi

WORLD_PATH="$WORLDPATH/$WORLD_FILENAME"
if [ ! -f "$CONFIGPATH/$CONFIG_FILENAME" ]; then
    echo "Server configuration not found, running with default server configuration."
    echo "Please ensure your desired $CONFIG_FILENAME file is volumed into docker: -v <path_to_config_file>:$CONFIGPATH"
    cp ./serverconfig-default.txt $CONFIGPATH/$CONFIG_FILENAME
fi

# variable to capture the command instead of running it directly
SERVER_CMD=""

if [ -z "$WORLD_FILENAME" ]; then
    echo "No world file specified in environment WORLD_FILENAME."
    # fixed: checking arg count instead of string content to avoid syntax errors
    if [ $# -eq 0 ]; then
        echo "Running server setup..."
    else
        echo "Running server with command flags: $@"
    fi
    SERVER_CMD="$EXECUTABLE -config \"$CONFIGPATH/$CONFIG_FILENAME\" -logpath \"$LOGPATH\" $@"
else
    echo "Environment WORLD_FILENAME specified"
    if [ -f "$WORLD_PATH" ]; then
        echo "Loading to world $WORLD_FILENAME..."
        SERVER_CMD="$EXECUTABLE -config \"$CONFIGPATH/$CONFIG_FILENAME\" -logpath \"$LOGPATH\" -world \"$WORLD_PATH\" $@"
    else
        echo "Unable to locate $WORLD_PATH."
        echo "Please make sure your world file is volumed into docker: -v <path_to_world_file>:$WORLDPATH"
        exit 1
    fi
fi

echo "Starting Terraria Server in Tmux..."

# ensure log file exists
touch /terraria-server/server.log

# start tmux (detached) with custom config and pipe output to log
tmux -f /terraria-server/tmux.conf new-session -d -s terraria "$SERVER_CMD" \; pipe-pane -o -t terraria 'cat > /terraria-server/server.log'

# start logging in the background so we can see output
tail -f /terraria-server/server.log &
TAIL_PID=$!

# watchdog loop: wait for the tmux session (server) to finish
# if the server crashes or stops, this loop ends
while tmux has-session -t terraria 2>/dev/null; do
    sleep 5
done

# if we reach here, the server stopped unexpectedly
echo "Tmux session ended. Stopping container."
kill $TAIL_PID
exit 0