FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

# Download and install TShock
ADD https://github.com/Pryaxis/TShock/releases/download/v4.4.0-pre2/TShock_4.4.0_226_Pre2_Terraria1.4.0.2.zip /
RUN unzip TShock_4.4.0_226_Pre2_Terraria1.4.0.2.zip -d /tshock && \
    rm TShock_4.4.0_226_Pre2_Terraria1.4.0.2.zip && \
    chmod +x /tshock/tshock/TerrariaServer.exe

FROM mono:6.8.0.96

LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

# documenting ports
EXPOSE 7777 7878

# add terraria user to run as
RUN groupadd -r terraria && \
    useradd -m -r -g terraria terraria

# copy in bootstrap
COPY --chown=terraria:terraria bootstrap.sh /tshock/bootstrap.sh

# copy game files
COPY --chown=terraria:terraria --from=base /tshock/* /tshock

# create directories
RUN mkdir /world && \
    mkdir -p /tshock/logs && \
    mv /tshock/ServerPlugins /tshock/_ServerPlugins && \
    mkdir -p /tshock/ServerPlugins &&  \
    chmod +x /tshock/bootstrap.sh && \
    chown -R terraria:terraria /world /tshock/logs /tshock/ServerPlugins /tshock/_ServerPlugins

# Allow for external data
VOLUME ["/world", "/tshock/logs", "/tshock/ServerPlugins"]

# Set working directory to server
WORKDIR /tshock

USER terraria

# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
