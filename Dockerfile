ARG ARCH=amd64
FROM balenalib/${ARCH}-debian:stretch

LABEL maintainer="Julio Gutierrez <bubuntux@gmail.com>"

HEALTHCHECK --timeout=15s --interval=60s --start-period=120s \
            CMD curl -fL 'https://api.ipify.org' || exit 1

ENV PROTOCOL=UDP \
    KILL_SWITCH=enabled \
    OBFUSCATE=disabled \
    CYBER_SEC=disabled \
    DNS=disabled \
    PORTS=all 

#CROSSRUN [ "cross-build-start" ]
ARG NORDVPN_BIN_VERSION=2.2.0-2
ARG NORDVPN_BIN_ARCH=amd64
RUN echo "**** install dependencies ****" && \
    apt-get update && apt-get install expect openvpn procps net-tools iptables xsltproc && \
    echo "**** install nordvpn binary ****" && \
    curl "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_${NORDVPN_BIN_VERSION}_${NORDVPN_BIN_ARCH}.deb" -o /tmp/nordvpn.deb && \
    dpkg --force architecture -i /tmp/nordvpn.deb && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*
#CROSSRUN [ "cross-build-start" ]

COPY nordVpn.sh /usr/bin 
CMD /usr/bin/nordVpn.sh
