FROM alpine:3.15.0 AS base

RUN apk add --update-cache \
    unzip

# add the bootstrap file
COPY bootstrap.sh /tshock/bootstrap.sh

ENV TSHOCKVERSION=v5.1.1
ENV TSHOCKZIP=TShock-5.1.1-for-Terraria-1.4.4.8-linux-x64-Release.zip

# Download and unpack TShock
ADD https://github.com/Pryaxis/TShock/releases/download/$TSHOCKVERSION/$TSHOCKZIP /
RUN unzip $TSHOCKZIP -d /tshock && \    
    tar -xvf /tshock/*.tar -C /tshock && \
    rm $TSHOCKZIP && \
    chmod +x /tshock/TShock.Server && \
    # add executable perm to bootstrap
    chmod +x /tshock/bootstrap.sh

# do not use -slim due to mysql/tshock requirements
FROM mcr.microsoft.com/dotnet/runtime:6.0

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
    apt-get install -y nuget mariadb-client jq && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# copy game files
COPY --from=base /tshock/ /tshock/

# Set working directory to server
WORKDIR /tshock

# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
