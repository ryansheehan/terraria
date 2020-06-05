FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

# add the bootstrap file
COPY bootstrap.sh /tshock/bootstrap.sh

ENV TSHOCKVERSION=v4.4.0-pre11
ENV TSHOCKZIP=TShock4.4.0_Pre11_Terraria1.4.0.5.zip

# Download and unpack TShock
ADD https://github.com/Pryaxis/TShock/releases/download/$TSHOCKVERSION/$TSHOCKZIP /
RUN unzip $TSHOCKZIP -d /tshock && \
    rm $TSHOCKZIP && \
    chmod +x /tshock/TerrariaServer.exe && \
    # add executable perm to bootstrap
    chmod +x /tshock/bootstrap.sh

FROM mono:6.8.0.96-slim

LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

# documenting ports
EXPOSE 7777 7878

# env used in the bootstrap
ENV CONFIGPATH=/root/.local/share/Terraria/Worlds
ENV LOGPATH=/tshock/logs
ENV WORLD_FILENAME=""

# Allow for external data
VOLUME ["/root/.local/share/Terraria/Worlds", "/tshock/logs", "/plugins"]

# install nuget to grab tshock dependencies
RUN apt-get update -y && \
    apt-get install -y nuget && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# copy game files
COPY --from=base /tshock/ /tshock/

# Set working directory to server
WORKDIR /tshock

# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
