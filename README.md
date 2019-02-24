# [bubuntux/NordVPN](https://github.com/bubuntux/nordvpn)

<p>
    <img src="https://badgen.net/github/license/bubuntux/nordvpn"/>
    <img src="https://images.microbadger.com/badges/image/bubuntux/nordvpn.svg"/>
    <img src="https://badgen.net/docker/pulls/bubuntux/nordvpn?icon=docker&label=pulls"/>
    <img src="https://badgen.net/docker/stars/bubuntux/nordvpn?icon=docker&label=stars"/>
    <img src="https://badgen.net/github/forks/bubuntux/nordvpn?icon=github&label=forks"/>
    <img src="https://badgen.net/github/stars/bubuntux/nordvpn?icon=github&label=stars"/>
    <img src="https://badgen.net/github/status/bubuntux/nordvpn"/>
</p>

This is a NordVPN client docker container that uses the official [binaries](https://nordvpn.com/download/linux/). It makes routing containers' traffic through NordVPN easy.

[![logo](https://github.com/bubuntux/nordvpn/raw/master/NordVpn_logo.png)](https://nordvpn.com/)

# Supported Architectures

This image use [docker manifest for multi-platform awareness](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list). 

Simply pulling `bubuntux/nordvpn` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

| Architecture | Tag | Tested |
| :----: | :---: | :-: |
| Linux x86-64 | amd64-latest | X |
| ARMv7 32-bit | armv7hf-latest | X |
| ARMv8 64-bit | aarch64-latest | - |
| ARMv5 32-bit | armv5e-latest | - |
| x86/i686 | i386-latest | - |


# How to use this image

This container was designed to be started first to provide a connection to other containers (using `--net=container:vpn`, see below *Starting an NordVPN client instance*).

**NOTE**
- More than the basic privileges are needed for NordVPN. With docker 1.2 or newer you can use the `--cap-add=NET_ADMIN` and `--device /dev/net/tun` options. Earlier versions should run in privileged mode.
- **Keep STDIN open even if not attached**, so even when running `docker run -d ...` the parameter `-i` should also be included

## Starting an NordVPN instance

    docker run -ti --cap-add=NET_ADMIN --device /dev/net/tun --name vpn \
                -e USER=user@email.com -e PASS=password \ 
                -e COUNRTY="country" -d bubuntux/nordvpn

Once it's up other containers can be started using it's network connection:

    docker run -it --net=container:vpn -d some/docker-container

## Local Network access to services connecting to the internet through the VPN.

The environment variable NETWORK must be your local network that you would connect to the server running the docker containers on. Running the following on your docker host should give you the correct network: `ip route | awk '!/ (docker0|br-)/ && /src/ {print $1}'`

    docker run -ti --cap-add=NET_ADMIN --device /dev/net/tun --name vpn \
                -p 8080:80 -e NETWORK=192.168.1.0/24 \ 
                -e USER=user@email.com -e PASS=password -d bubuntux/nordvpn                

Now just create the second container _without_ the `-p` parameter, only inlcude the `--net=container:vpn`, the port should be declare in the vpn container.

    docker run -ti --rm --net=container:vpn -d bubuntux/riot-web

now the service provided by the second container would be available from the host machine (http://localhost:8080) or anywhere inside the local network (http://192.168.1.xxx:8080).

## docker-compose

```
---
version: "3"
services:
  vpn:
    image: bubuntux/nordvpn
    container_name: nordvpn
    cap_add:
      - net_admin
    devices:
      - /dev/net/tun
    environment:
      - USER=user@email.com
      - PASS=password
      - COUNRTY=United_States
      - CITY=New_York
      - PROTOCOL=TCP
      - NETWORK=192.168.1.0/24
      - TZ=America/Mexico_City
    ports:
      - 8080:80
    stdin_open: true
    restart: unless-stopped
  
  web:
    image: nginx
    network_mode: service:vpn
   
```
**NOTE**
 `stdin_open: true` is required even when running on detached mode -d

## ENVIRONMENT VARIABLES

* `USER`        - [Required] User for NordVPN account.
* `PASS`        - [Required] Password for NordVPN account.
* `COUNTRY`     - Connect to an specify country (IE United_States or US). 
* `CITY`        - Connect to an specific city (IE Dallas or Las_Vegas). Country is required, when empty will connect to recommended server.
* `PROTOCOL`    - Specify OpenVPN protocol. Only one protocol can be selected. Allowed protocols: UDP(default), TCP.
* `KILL_SWITCH` - In case your VPN connection drops, NordVPN Kill Switch will automatically block your device or terminate certain programs from accessing the Internet outside the secure VPN tunnel. Allowed values: enabled(default), disabled.
* `OBFUSCATE`   - Servers that can bypass internet restrictions such as network firewalls. Allowed values: enabled, disabled(default).
* `CYBER_SEC`   - When enabled, the CyberSec feature will automatically block suspicious websites so that no malware or other cyber threats can infect your device. Additionally, no flashy ads will come into your sight. Allowed values: enabled, disabled(default).
* `DNS`         - DNS server to use, disabled by default
* `PORTS`       - Space separate ports that are allowed for input connections (all by default).
* `NETWORK`     - CIDR network (IE 192.168.1.0/24), add a route to allows replies once the VPN is up.

**Note** CyberSec & DNS. Setting CyberSec disables user defined DNS servers and vice versa.

## Issues

If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/bubuntux/nordvpn/issues).
