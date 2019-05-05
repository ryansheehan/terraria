FROM ubuntu:14.04.4

MAINTAINER Ryan Sheehan <rsheehan@gmail.com>

# Create symbolic link to ServerLog.txt
RUN mkdir /world /tshock && \
    touch /world/ServerLog.txt && \
    ln -s /world/ServerLog.txt /tshock/ServerLog.txt && \
    rm -rf /world

# Add mono repository
# Update and install mono and a zip utility
# fix for favorites.json error
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list && \
    apt-get update && apt-get install -y \
    zip \
    mono-complete && \
    apt-get clean && \
    favorites_path="/root/My Games/Terraria" && mkdir -p "$favorites_path" && echo "{}" > "$favorites_path/favorites.json"

# Download and install TShock
ENV TSHOCK_VERSION=4.3.26 \
    TSHOCK_FILE_POSTFIX=""

ADD https://github.com/NyxStudios/TShock/releases/download/v$TSHOCK_VERSION/tshock_$TSHOCK_VERSION.zip /
RUN unzip tshock_$TSHOCK_VERSION.zip -d /tshock && \
    rm tshock_$TSHOCK_VERSION.zip && \
    chmod 777 /tshock/TerrariaServer.exe

# Allow for external data
VOLUME ["/world", "/tshock/ServerPlugins"]

# Set working directory to server
WORKDIR /tshock

# run the server
ENTRYPOINT ["mono", "--server", "--gc=sgen", "-O=all", "TerrariaServer.exe", "-configpath", "/world", "-worldpath", "/world", "-logpath", "/world"]
