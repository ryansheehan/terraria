FROM alpine:3.15.0 AS base

RUN apk add --update-cache \
    unzip

# add the bootstrap file
COPY bootstrap.sh /terraria-server/bootstrap.sh

ENV DL_LINK=https://terraria.org/api/download/pc-dedicated-server/terraria-server-1445.zip
ENV DL_VERSION=1445
ENV DL_FILE=terraria-server-1445.zip

ADD $DL_LINK /$DL_FILE

RUN unzip /$DL_FILE -d /terraria && \
    mv /terraria/$DL_VERSION/Linux/* /terraria-server && \
    #Linux subfolder does not include any config text file, oddly.
    mv /terraria/$DL_VERSION/Windows/serverconfig.txt /terraria-server/serverconfig-default.txt && \
    chmod +x /terraria-server/TerrariaServer && \
    chmod +x /terraria-server/TerrariaServer.bin.x86_64

FROM mono:6.10.0.104-slim
LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

# documenting ports
EXPOSE 7777

# env used in the bootstrap
ENV LOGPATH=/terraria-server/logs
ENV WORLDPATH=/root/.local/share/Terraria/Worlds
ENV WORLD_FILENAME=""
ENV CONFIGPATH=/config
ENV CONFIG_FILENAME="serverconfig.txt"

VOLUME [ "${WORLDPATH}", "${CONFIGPATH}", "${LOGPATH}" ]

COPY --from=base /terraria-server/ /terraria-server/

# Set working directory to server
WORKDIR /terraria-server

ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]

