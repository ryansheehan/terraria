FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

# Download and install TShock
ENV TSHOCK_VERSION=4.3.26 

ADD https://github.com/Pryaxis/TShock/releases/download/v4.4.0-pre1/TShock_4.4.0_226_Pre1_Terraria1.4.0.2.zip /
RUN unzip TShock_4.4.0_226_Pre1_Terraria1.4.0.2.zip -d /tshock && \
    rm TShock_4.4.0_226_Pre1_Terraria1.4.0.2.zip && \
    chmod 777 /tshock/TerrariaServer.exe

FROM mono:6.8.0.96

LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

# Create symbolic link to ServerLog.txt
# fix for favorites.json error
RUN mkdir /world /tshock && \
    touch /world/ServerLog.txt && \
    ln -s /world/ServerLog.txt /tshock/ServerLog.txt && \
    rm -rf /world && \
    favorites_path="/root/My Games/Terraria" && \
    mkdir -p "$favorites_path" && \
    echo "{}" > "$favorites_path/favorites.json"

COPY --from=base /tshock /tshock

# Allow for external data
VOLUME ["/world", "/tshock/ServerPlugins"]

# Set working directory to server
WORKDIR /tshock

# run the server
ENTRYPOINT ["mono", "--server", "--gc=sgen", "-O=all", "TerrariaServer.exe", "-configpath", "/world", "-worldpath", "/world", "-logpath", "/world"]
