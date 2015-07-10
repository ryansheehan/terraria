FROM ubuntu:latest

MAINTAINER Ryan Sheehan <rsheehan@gmail.com>

ENV TSHOCK_VERSION 4.3.2
ENV TSHOCK_FILE_POSTFIX -pre1

# Allow for external data
VOLUME ["/tshock/world"]

# Add mono repository
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
  echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list

# Update and install mono and a zip utility
RUN apt-get update && apt-get install -y \
  zip \
  mono-complete && \
  apt-get clean

# fix for favorites.json error
RUN favorites_path="/root/My Games/Terraria" && mkdir -p "$favorites_path" && echo "{}" > "$favorites_path/favorites.json"

# Download and install TShock
ADD https://github.com/NyxStudios/TShock/releases/download/v$TSHOCK_VERSION/tshock_$TSHOCK_VERSION$TSHOCK_FILE_POSTFIX.zip /
RUN unzip tshock_$TSHOCK_VERSION$TSHOCK_FILE_POSTFIX.zip -d /tshock
RUN rm tshock_$TSHOCK_VERSION$TSHOCK_FILE_POSTFIX.zip

# Set working directory to server
WORKDIR /tshock

# Set permissions
RUN chmod 777 TerrariaServer.exe

# run the server
ENTRYPOINT ["mono", "--server", "--gc=sgen", "-O=all", "TerrariaServer.exe", "-configpath", "/tshock/world", "-worldpath", "/tshock/world", "-logpath", "/tshock/world"]
