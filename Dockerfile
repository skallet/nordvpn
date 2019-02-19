ARG ARCH
FROM balenalib/${ARCH}-debian:stretch

LABEL maintainer="Julio Gutierrez <bubuntux@gmail.com>"

ARG ARCH
ARG VER
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
RUN curl "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_${VER}_$(echo ${ARCH} | sed 's/v7//').deb" -o /tmp/nordvpn.deb && \
    apt-get update && apt-get upgrade && \
    apt-get install expect openvpn /tmp/nordvpn.deb && \
    apt-get autoremove && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#CROSSRUN [ "cross-build-end" ]

COPY nordVpn.sh /usr/bin 
CMD /usr/bin/nordVpn.sh
