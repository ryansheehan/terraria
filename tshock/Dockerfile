FROM alpine:3.17.3 AS base

RUN apk add --update-cache \
    curl unzip

# add the bootstrap file
COPY bootstrap.sh /tshock/bootstrap.sh

ENV TSHOCKVERSION=v5.2.1

# Download and unpack TShock
RUN set -eux; \
    arch="$(apk --print-arch)"; \
    case "$arch" in \
        'x86_64') \
            export TSHOCKZIP='TShock-5.2.1-for-Terraria-1.4.4.9-linux-x64-Release.zip'; \
            ;; \
        'aarch64') \
            export TSHOCKZIP='TShock-5.2.1-for-Terraria-1.4.4.9-linux-arm64-Release.zip'; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$arch'."; exit 1 ;; \
    esac; \
    curl -L -o /$TSHOCKZIP https://github.com/Pryaxis/TShock/releases/download/$TSHOCKVERSION/$TSHOCKZIP; \
    unzip $TSHOCKZIP -d /tshock ; \    
    tar -xvf /tshock/*.tar -C /tshock ; \
    rm $TSHOCKZIP ; \
    chmod +x /tshock/TShock.Server ; \
    # add executable perm to bootstrap
    chmod +x /tshock/bootstrap.sh

# do not use -slim due to mysql/tshock requirements
FROM mcr.microsoft.com/dotnet/runtime:6.0

LABEL org.opencontainers.image.authors="Ryan Sheehan <rsheehan@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/ryansheehan/terraria"
LABEL org.opencontainers.image.documentation="Dockerfile for Terraria"
LABEL org.opencontainers.image.source="https://github.com/ryansheehan/terraria/blob/master/tshock/Dockerfile"

# documenting ports
EXPOSE 7777 7878

# env used in the bootstrap
ENV CONFIGPATH=/root/.local/share/Terraria/Worlds
ENV LOGPATH=/tshock/logs
ENV WORLD_FILENAME=""

# Allow for external data
VOLUME ["/root/.local/share/Terraria/Worlds", "/tshock/logs", "/tshock/ServerPlugins", "/config"]

# install nuget to grab tshock dependencies
RUN apt-get update -y && \
    apt-get install -y nuget mariadb-client jq && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# copy game files
COPY --from=base /tshock/ /tshock/
# Copy the plugin files to a place that bootstrap can copy them to the plugins folder at runtime
COPY --from=base /tshock/ServerPlugins/ /plugins

# Set working directory to server
WORKDIR /tshock

# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
