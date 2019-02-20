#!/bin/bash

/etc/init.d/nordvpn restart && sleep 1

expect -c 'spawn nordvpn login 
           expect {
             "sername: " { 
               send "$env(USER)\r" 
               expect "assword: "
               send "$env(PASS)\r"
             }
             eof    	    
           }
           interact'

if [ ! -f /root/.config/nordvpn/auth ]; then
  echo "Invalid User"
  exit 1
fi

nordvpn set protocol ${PROTOCOL}
nordvpn set killswitch ${KILL_SWITCH}
nordvpn set cybersec ${CYBER_SEC}
nordvpn set obfuscate ${OBFUSCATE}
nordvpn set dns ${DNS}

COUNTRY=(${COUNTRY//;/ }) #keep backward compatibility
nordvpn connect ${COUNTRY[0]} ${CITY}

if [[ -n ${PORTS} ]]; then
  shopt -s nocasematch
  case "${PORTS}" in
    "all" ) iptables -P INPUT ACCEPT; echo "Full input access enabled";;
    *) for port in ${PORTS}; do nordvpn whitelist add port ${port}; done;;
  esac	
fi

return_route() {
  local network="$1" gw="$(ip route | awk '/default/ {print $3}')"
  ip route add to ${network} via ${gw} dev eth0
  iptables -A OUTPUT --destination ${network} -j ACCEPT
  echo "Added network route ${network}"
}
[[ -n ${NETWORK} ]] && for net in ${NETWORK}; do return_route $net; done

tail -f --pid=$(cat /var/run/nordvpn.pid) /var/log/nordvpn.log
