FROM alpine:3.15.0 AS base

RUN apk add --update-cache \
    unzip

ENV DL_LINK=https://terraria.org/api/download/mobile-dedicated-server/MobileTerrariaServer.zip
ENV DL_VERSION=1_4_0_5
ENV DL_FILE=MobileTerrariaServer.zip

ADD $DL_LINK /$DL_FILE

RUN unzip /$DL_FILE -d /terraria-zip && \ 
    unzip /terraria-zip/Linux_MobileServer_${DL_VERSION}.zip -d /terraria && \
    mkdir /terraria-server && \
    mv /terraria/ServerLinux/* /terraria-server && \
    rm /terraria-server/System* && \
    rm /terraria-server/Mono* && \
    rm /terraria-server/monoconfig && \
    rm /terraria-server/mscorlib.dll && \
    chmod +x /terraria-server/TerrariaServer && \
    chmod +x /terraria-server/TerrariaServer.bin.x86 && \
    chmod +x /terraria-server/TerrariaServer.bin.x86_64

FROM mono:6.12.0.122-slim
LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

EXPOSE 7777

VOLUME ["/root/.local/share/Terraria/Mobile", "/config"]

COPY --from=base /terraria-server/ /terraria-server/

ENTRYPOINT ["mono", "--server", "--gc=sgen", "-O=all", "/terraria-server/TerrariaServer.exe"]
