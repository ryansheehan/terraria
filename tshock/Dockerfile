ARG DOTNETRUNTIME_VERSION=6.0
FROM alpine:3.21 AS base

# Available environment variables:
# TSHOCKVERSION="v5.2.2"
# WORLD_FILENAME="world.wld"
# CONFIGPATH="/tshock/config"
# LOGPATH="/tshock/logs"

RUN apk add --update-cache \
    curl unzip

# add the bootstrap file
COPY bootstrap.sh /tshock/bootstrap.sh

ENV TSHOCKVERSION=v5.2.2

# Download and unpack TShock
# x86_64:   https://github.com/Pryaxis/TShock/releases/download/v5.2.2/TShock-5.2.2-for-Terraria-1.4.4.9-linux-amd64-Release.zip
# aarch64:  https://github.com/Pryaxis/TShock/releases/download/v5.2.2/TShock-5.2.2-for-Terraria-1.4.4.9-linux-arm64-Release.zip
RUN set -eux; \
    arch="$(apk --print-arch)"; \
    case "$arch" in \
    'x86_64') arch_suffix="amd64" ;; \
    'aarch64') arch_suffix="arm64" ;; \
    *) \
      echo >&2 "error: unsupported architecture '$arch'."; \
      exit 1 \
      ;; \
    esac; \
    # Get the asset list from GitHub API
    if [ "${TSHOCKVERSION}" = "latest" ]; then \
        RELEASE_URL="https://api.github.com/repos/Pryaxis/TShock/releases/latest"; \
    else \
        RELEASE_URL="https://api.github.com/repos/Pryaxis/TShock/releases/tags/$TSHOCKVERSION"; \
    fi; \
    TSHOCKURL=$(curl -s $RELEASE_URL | grep browser_download_url | grep "linux-$arch_suffix-Release.zip" | cut -d '"' -f 4); \
    TSHOCKZIP=$(basename $TSHOCKURL); \
    curl -L -o "/$TSHOCKZIP" "$TSHOCKURL"; \
    unzip "$TSHOCKZIP" -d "/tshock"; \
    tar -xvf "/tshock/"*.tar -C "/tshock"; \
    rm "$TSHOCKZIP"; \
    chmod +x "/tshock/TShock.Server"; \
    # add executable perm to bootstrap
    chmod +x "/tshock/bootstrap.sh"

# do not use -slim due to mysql/tshock requirements
FROM mcr.microsoft.com/dotnet/runtime:${DOTNETRUNTIME_VERSION} AS runtime

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
