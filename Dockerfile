ARG ARCH=amd64
FROM balenalib/${ARCH}-debian:stretch
ARG ARCH

LABEL maintainer="Julio Gutierrez <bubuntux@gmail.com>"

ENV PROTOCOL=UDP \
    KILL_SWITCH=enabled \
    OBFUSCATE=disabled \
    CYBER_SEC=disabled \
    DNS=disabled \
    PORTS=all 

VOLUME ["/root/.config/nordvpn/"]

HEALTHCHECK --timeout=15s --interval=60s --start-period=120s \
            CMD curl -fL 'https://api.ipify.org' || exit 1

#CROSSRUN [ "cross-build-start" ]
ARG NORDVPN_BIN_VERSION=2.2.0-2
RUN curl -s "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_${NORDVPN_BIN_VERSION}_$(echo ${ARCH} | sed 's/v7//').deb" -o /tmp/nordvpn.deb && \
    apt-get update -qq && apt-get upgrade -qq && \
    apt-get install expect openvpn /tmp/nordvpn.deb -qq && \
    apt-get autoremove -qq && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#CROSSRUN [ "cross-build-end" ]

COPY nordVpn.sh /usr/bin 
CMD /usr/bin/nordVpn.sh
