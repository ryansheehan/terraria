FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

ENV DL_LINK=https://terraria.org/api/download/pc-dedicated-server/terraria-server-1423.zip
ENV DL_VERSION=1423
ENV DL_FILE=terraria-server-1423.zip

ADD $DL_LINK /$DL_FILE

RUN unzip /$DL_FILE -d /terraria && \
    mkdir /terraria-server && \
    mv /terraria/$DL_VERSION/Linux/* /terraria-server && \
    chmod +x /terraria-server/TerrariaServer && \
    chmod +x /terraria-server/TerrariaServer.bin.x86_64

FROM mono:6.8.0.96-slim
LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

EXPOSE 7777

# env used in the bootstrap
ENV CONFIGPATH=/root/.local/share/Terraria/Worlds
ENV WORLD_FILENAME=""

VOLUME ["/root/.local/share/Terraria/Worlds", "/config"]

COPY --from=base /terraria-server/ /terraria-server/

# add the bootstrap file
COPY bootstrap.sh /terraria-server/bootstrap.sh
RUN chmod +x /terraria-server/bootstrap.sh
ENTRYPOINT ["/terraria-server/bootstrap.sh"]
