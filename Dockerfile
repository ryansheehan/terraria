FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

# Download and install TShock
ADD https://github.com/Pryaxis/TShock/releases/download/v4.4.0-pre3/TShock_4.4.0_226_Pre3_Terraria1.4.0.2.zip /
RUN unzip TShock_4.4.0_226_Pre3_Terraria1.4.0.2.zip -d /tshock && \
    rm TShock_4.4.0_226_Pre3_Terraria1.4.0.2.zip && \
    chmod +x /tshock/tshock/TerrariaServer.exe

FROM mono:6.8.0.96-slim

LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

# documenting ports
EXPOSE 7777 7878

ENV WORLDPATH=/world
ENV CONFIGPATH=/world
ENV LOGPATH=/tshock/logs

# copy in bootstrap
COPY bootstrap.sh /tshock/bootstrap.sh

# copy game files
COPY --from=base /tshock/* /tshock

# install nuget to grab tshock dependencies
RUN apt-get update -y && \
    apt-get install -y nuget && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    # create directories
    mkdir /world && \
    mkdir /plugins && \
    mkdir -p /tshock/logs && \
    chmod +x /tshock/bootstrap.sh

# Allow for external data
VOLUME ["/world", "/tshock/logs", "/plugins"]

# Set working directory to server
WORKDIR /tshock

# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
