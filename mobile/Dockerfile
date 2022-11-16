FROM alpine:3.16.3 AS base

RUN apk add --update-cache \
    unzip

ENV DL_LINK=https://terraria.org/api/download/mobile-dedicated-server/terraria-server-1445.zip
ENV DL_VERSION=1445
ENV DL_FILE=terraria-server-1445.zip

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
LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

EXPOSE 7777

VOLUME ["/root/.local/share/Terraria/Worlds", "/config"]

COPY --from=base /terraria-server/ /terraria-server/

ENTRYPOINT ["mono", "--server", "--gc=sgen", "-O=all", "/terraria-server/TerrariaServer.exe"]
