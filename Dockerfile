FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

# Download and install TShock
ADD https://github.com/Pryaxis/TShock/releases/download/v4.4.0-pre4/TShock_4.4.0_226_Pre4v2_Terraria1.4.0.2.zip /
RUN unzip TShock_4.4.0_226_Pre4v2_Terraria1.4.0.2.zip -d /tshock && \
    rm TShock_4.4.0_226_Pre4v2_Terraria1.4.0.2.zip && \
    chmod +x /tshock/tshock/TerrariaServer.exe

# Add bootstrap.sh and make sure it's executable.
# This will be pulled into the final stage.
ADD bootstrap.sh .
RUN chmod +x bootstrap.sh

FROM mono:6.8.0.96-slim

LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

# documenting ports
EXPOSE 7777 7878

ENV WORLDPATH=/world
ENV CONFIGPATH=/world
ENV LOGPATH=/tshock/logs

# add terraria user to run as
RUN groupadd -r terraria && \
    useradd -m -r -g terraria terraria && \
    # install nuget to grab tshock dependencies
    apt-get update -y && \
    apt-get install -y nuget && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    # create directories
    mkdir /tshock && \
    mkdir /world && \
    mkdir /plugins && \
    mkdir -p /tshock/logs && \
    chown -R terraria:terraria /tshock /world /plugins

# copy in bootstrap
COPY --chown=terraria:terraria --from=base bootstrap.sh /tshock/bootstrap.sh

# copy game files
COPY --chown=terraria:terraria --from=base /tshock/* /tshock

# Allow for external data
VOLUME ["/world", "/tshock/logs", "/plugins"]

# Set working directory to server
WORKDIR /tshock

USER terraria

# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
