FROM alpine:3.17.3 AS base

RUN apk add --update-cache \
    unzip

ENV DL_VERSION=1449
ENV DL_LINK=https://terraria.org/api/download/mobile-dedicated-server/terraria-server-$DL_VERSION.zip
ENV DL_FILE=terraria-server-$DL_VERSION.zip

ADD $DL_LINK /$DL_FILE

RUN unzip $DL_FILE && \ 
    mkdir ./terraria-server  && \
    mv ./$DL_VERSION/Linux/* ./terraria-server && \
    rm ./terraria-server/System* && \
    rm ./terraria-server/Mono* && \
    rm ./terraria-server/monoconfig && \
    rm ./terraria-server/mscorlib.dll && \
    rm -r ./$DL_VERSION && \
    rm -r ./$DL_FILE && \
    chmod +x ./terraria-server/TerrariaServer && \
    chmod +x ./terraria-server/TerrariaServer.bin.x86_64

FROM mono:6.12.0.182

LABEL org.opencontainers.image.authors="Ryan Sheehan <rsheehan@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/ryansheehan/terraria"
LABEL org.opencontainers.image.documentation="Dockerfile for Terraria"
LABEL org.opencontainers.image.source="https://github.com/ryansheehan/terraria/blob/master/mobile/Dockerfile"

EXPOSE 7777

VOLUME ["/root/.local/share/Terraria/Worlds", "/config"]

COPY --from=base /terraria-server/ /terraria-server/

ENTRYPOINT ["mono", "--server", "--gc=sgen", "-O=all", "/terraria-server/TerrariaServer.exe"]
