FROM alpine:3.17.3 AS base

RUN apk add --update-cache \
    curl unzip

# add the bootstrap file
COPY bootstrap.sh /tshock/bootstrap.sh

ENV TSHOCKVERSION=v5.2.0

# Download and unpack TShock
RUN set -eux; \
    arch="$(apk --print-arch)"; \
    case "$arch" in \
        'x86_64') \
            export TSHOCKZIP='TShock-5.2-for-Terraria-1.4.4.9-linux-x64-Release.zip'; \
            ;; \
        'aarch64') \
            export TSHOCKZIP='TShock-5.2-for-Terraria-1.4.4.9-linux-arm64-Release.zip'; \
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

LABEL org.opencontainers.image.authors="Logan Saso <logansaso+tech@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/logaintech/terraria"
LABEL org.opencontainers.image.documentation="Dockerfile for Terraria"
LABEL org.opencontainers.image.source="https://github.com/logansaso/terraria/blob/master/tshock/Dockerfile"

# documenting ports
EXPOSE 7777 7878

# env used in the bootstrap
ENV WORLD_PATH=/root/.local/share/Terraria/Worlds
ENV CONFIG_PATH=/config
ENV LOG_PATH=/tshock/logs

# Allow for external data
VOLUME ["/root/.local/share/Terraria/Worlds", "/config", "/tshock/logs", "/tshock/ServerPlugins"]

# install nuget to grab tshock dependencies
RUN apt-get update -y && \
    apt-get install -y nuget mariadb-client jq && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# copy game files
COPY --from=base /tshock/ /tshock/
COPY --from=base /tshock/ServerPlugins /plugins/

# Set working directory to server
WORKDIR /tshock

ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
