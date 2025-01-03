# -- Build ---
FROM azul/zulu-openjdk-debian:21-latest AS build
LABEL Sebas Álvaro <https://asgg.cl>

ARG TARGETARCH
ARG MCVERSION=1.20

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/minecraft

COPY ./getfabricserver.sh /getfabricserver.sh
RUN chmod +x /getfabricserver.sh && \
    /getfabricserver.sh ${MCVERSION}

# --- Runtime ---
FROM azul/zulu-openjdk-debian:21-latest AS runtime
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
ARG GOSUVERSION=1.16
ARG RCON_CLI_VER=1.6.0

RUN set -eux && \
    curl -fsSL "https://github.com/tianon/gosu/releases/download/${GOSUVERSION}/gosu-${TARGETARCH}" -o /usr/bin/gosu && \
    chmod +x /usr/bin/gosu && \
    gosu nobody true

WORKDIR /data
COPY --from=build /opt/minecraft/fabric.jar /opt/minecraft/fabric.jar

ADD https://github.com/itzg/rcon-cli/releases/download/${RCON_CLI_VER}/rcon-cli_${RCON_CLI_VER}_linux_${TARGETARCH}.tar.gz /tmp/rcon-cli.tgz
RUN tar -x -C /usr/local/bin -f /tmp/rcon-cli.tgz rcon-cli && \
    rm /tmp/rcon-cli.tgz

VOLUME "/data"

EXPOSE 25565/tcp
EXPOSE 25565/udp

ARG memory_size=5G
ENV MEMORYSIZE=$memory_size

ARG java_flags="--add-modules=jdk.incubator.vector -Dlog4j2.formatMsgNoLookups=true -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs"
ENV JAVAFLAGS=$java_flags

WORKDIR /data

COPY /docker-entrypoint.sh /opt/minecraft
RUN chmod +x /opt/minecraft/docker-entrypoint.sh

# Entrypoint
ENTRYPOINT ["/opt/minecraft/docker-entrypoint.sh"]