FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

ENV DL_LINK=https://terraria.org/server/MobileTerrariaServer.zip
ENV DL_VERSION=1_4_0_5
ENV DL_FILE=MobileTerrariaServer.zip

ADD $DL_LINK /$DL_FILE

RUN unzip /$DL_FILE -d /terraria-zip && \ 
    unzip /terraria-zip/Linux_MobileServer_${DL_VERSION}.zip -d /terraria && \
    mkdir /terraria-server && \
    mv /terraria/ServerLinux/* /terraria-server && \
    chmod +x /terraria-server/TerrariaServer && \
    chmod +x /terraria-server/TerrariaServer.bin.x86 && \
    chmod +x /terraria-server/TerrariaServer.bin.x86_64

FROM mono:6.8.0.96-slim
LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

EXPOSE 7777

VOLUME ["/root/.local/share/Terraria/Worlds", "/config"]

COPY --from=base /terraria-server/ /terraria-server/

ENTRYPOINT ["/terraria-server/TerrariaServer"]
