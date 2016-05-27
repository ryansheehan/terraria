FROM ubuntu:14.04.4

MAINTAINER Ryan Sheehan <rsheehan@gmail.com>

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
ENV TSHOCK_DEV_BUILD 618
ENV TSHOCK_DEV_ZIP tshock_release.zip

ADD https://bamboo.tshock.co/browse/TERRA-TSHOCK-$TSHOCK_DEV_BUILD/artifact/shared/$TSHOCK_DEV_ZIP/$TSHOCK_DEV_ZIP /
RUN unzip $TSHOCK_DEV_ZIP -d /tshock
RUN rm $TSHOCK_DEV_ZIP

# Allow for external data
VOLUME ["/world", "/tshock/ServerPlugins"]

# Set working directory to server
WORKDIR /tshock

# Set permissions
RUN chmod 777 TerrariaServer.exe

# run the server
ENTRYPOINT ["mono", "--server", "--gc=sgen", "-O=all", "TerrariaServer.exe", "-configpath", "/world", "-worldpath", "/world", "-logpath", "/world"]
