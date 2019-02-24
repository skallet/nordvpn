ARG BASE_ARCH=amd64
FROM ${BASE_ARCH}/debian:stable-slim

ARG QEMU_ARCH
COPY qemu-${QEMU_ARCH}-static /usr/bin/

LABEL maintainer="Julio Gutierrez <bubuntux@gmail.com>"

HEALTHCHECK --timeout=15s --interval=60s --start-period=120s \
            CMD curl -fL 'https://api.ipify.org' || exit 1

ENV DEBIAN_FRONTEND=noninteractive \
    PROTOCOL=UDP \
    KILL_SWITCH=enabled \
    OBFUSCATE=disabled \
    CYBER_SEC=disabled \
    DNS=disabled \
    PORTS=all 

ARG NORDVPN_BIN_VERSION=2.2.0-2
ARG NORDVPN_BIN_ARCH=amd64
RUN echo "**** install dependencies ****" && \
    apt-get update && apt-get install -y wget expect openvpn procps net-tools iptables xsltproc && \
    echo "**** install nordvpn binary ****" && \
    wget "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_${NORDVPN_BIN_VERSION}_${NORDVPN_BIN_ARCH}.deb" -O /tmp/nordvpn.deb 
RUN dpkg --force architecture -i /tmp/nordvpn.deb && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

COPY nordVpn.sh /usr/bin 
CMD /usr/bin/nordVpn.sh
