ARG TERRARIA_SERVER_VERSION="1451"
ARG TERRARIA_SERVER_PATH="/terraria-server"
ARG CONFIG_PATH="/terraria/config"
ARG CONFIG_FILENAME="serverconfig.txt"
ARG LOG_PATH="/terraria/logs"
ARG ADDITIONAL_ARGS

FROM debian:trixie-slim AS base

# Set values as args so the second stage may inherit
ARG TERRARIA_SERVER_VERSION
ARG TERRARIA_SERVER_FILENAME="terraria-server-${TERRARIA_SERVER_VERSION}.zip"
ARG TERRARIA_SERVER_URL="https://terraria.org/api/download/pc-dedicated-server/${TERRARIA_SERVER_FILENAME}"
ARG TERRARIA_SERVER_PATH
ARG CONFIG_PATH
ARG CONFIG_FILENAME
ARG LOG_PATH

# Required to unzip terraria-server binaries
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y unzip

# Add server files from internet source
ADD "$TERRARIA_SERVER_URL" "/${TERRARIA_SERVER_FILENAME}"

RUN mkdir -p "$CONFIG_PATH" "$LOG_PATH" "$TERRARIA_SERVER_PATH"

RUN unzip "/$TERRARIA_SERVER_FILENAME" -d "/tmp/terraria/" \
    && mv "/tmp/terraria/${TERRARIA_SERVER_VERSION}/Linux/"* "$TERRARIA_SERVER_PATH" \
    && mv "/tmp/terraria/${TERRARIA_SERVER_VERSION}/Windows/${CONFIG_FILENAME}" "${CONFIG_PATH}/${CONFIG_FILENAME}"

# Calculate MD5 of modified serverconfig and save to file for later use
RUN md5sum "${CONFIG_PATH}/${CONFIG_FILENAME}" | cut -d' ' -f1 > "${CONFIG_PATH}/default-serverconfig.md5"

FROM debian:trixie-slim

# Inherited arguments
ARG TARGETARCH
ARG TERRARIA_SERVER_VERSION
ARG TERRARIA_SERVER_PATH
ARG CONFIG_PATH
ARG CONFIG_FILENAME
ARG LOG_PATH
ARG ADDITIONAL_ARGS

# Container labels
LABEL org.opencontainers.image.authors="Ryan Sheehan <rsheehan@gmail.com>"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/ryshe/terraria"
LABEL org.opencontainers.image.documentation="Container image for Terraria Server."
LABEL org.opencontainers.image.source="https://github.com/ryansheehan/terraria/blob/master/vanilla/Dockerfile"
LABEL org.opencontainers.image.version="$TERRARIA_SERVER_VERSION"

# Environment variables
ENV TERRARIA_SERVER_PATH=$TERRARIA_SERVER_PATH
ENV CONFIG_PATH="$CONFIG_PATH"
ENV CONFIG_FILENAME="$CONFIG_FILENAME"
ENV LOG_PATH="$LOG_PATH"
ENV DEFAULT_TERRARIA_SERVER_PATH=".local/share/Terraria"
ENV WORLD_FILENAME="Terraria.wld"
ENV TARGETARCH="${TARGETARCH}"
ENV ENTRYPOINT="entrypoint.sh"
ENV ADDITIONAL_ARGS="$ADDITIONAL_ARGS"

# Add terraria user and group to prevent needing to run the server as root (dangerous)
RUN groupadd -r terraria \
    && useradd -u 999 -r -g terraria -d "$TERRARIA_SERVER_PATH" -s /bin/sh terraria \
    && mkdir -p "$TERRARIA_SERVER_PATH" "${TERRARIA_SERVER_PATH}/${DEFAULT_TERRARIA_SERVER_PATH}" "$CONFIG_PATH" "$LOG_PATH"

# Copy files from previous stage and repository
COPY --from=base --chown=terraria:terraria --chmod=0550 "${TERRARIA_SERVER_PATH}/" "${TERRARIA_SERVER_PATH}/"
COPY --from=base --chown=terraria:terraria --chmod=0550 "${CONFIG_PATH}/" "${CONFIG_PATH}/"
COPY --chown=terraria:terraria --chmod=0550 "$ENTRYPOINT" "${TERRARIA_SERVER_PATH}/${ENTRYPOINT}"

# Make terraria user owner over relevant paths
RUN chown -R terraria:terraria "$LOG_PATH" "$TERRARIA_SERVER_PATH" \
    && chmod -R 770 "$LOG_PATH" "${TERRARIA_SERVER_PATH}/${DEFAULT_TERRARIA_SERVER_PATH}"

# Only install mono libraries output by `monodis --assemblyref TerrariaServer.exe`
# Reduces size by 40% compared to installing package 'mono-runtime'
RUN if [ "${TARGETARCH}" = "arm64" ] || [ "${TARGETARCH}" = "arm" ]; then \
        apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        ca-certificates \
        mono-runtime-common \
        libmono-corlib4.5-cil \
        libmono-system4.0-cil \
        libmono-system-core4.0-cil \
        libmono-system-drawing4.0-cil \
        libmono-system-windows-forms4.0-cil \
        libmono-system-runtime-serialization4.0-cil \
        libmono-windowsbase4.0-cil \
        && rm -rf "/var/lib/apt/lists/"* \
        && mv /terraria-server/System.dll /usr/lib/mono/4.5/System.dll; \
    fi

# Set working directory to server
WORKDIR "/terraria-server"

# Switch to terraria user
USER terraria

# Document default Terraria server port
EXPOSE 7777

ENTRYPOINT [ "/bin/sh", "entrypoint.sh" ]
