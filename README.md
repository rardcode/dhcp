# Ipv4/ipv6 Debian based dhcp server

## How to use
### After first run it make conf file in `./data` dir. Change it with your parameters and ... relauch it!

### ...by docker run:
```
docker run --rm -d \
--net host \
-v ./data:/data \
-e DHCP4=1 -e DHCP6=0 -e TZ=Europe/Rome \
--name dhcp rardcode/dhcp
```

### ...by docker-compose file:
```
services:
  dhcp:
    image: rardcode/dhcp
    container_name: dhcp
    environment:
      - TZ=Europe/Rome
      #- DHCP4=0 # (decomment for disable DHCPv4 server, default enabled|1)
      #- DHCP6=1 # (enable DHCPv6 server, default disabled|0)
    volumes:
    - ./data:/data
    network_mode: host
    restart: unless-stopped
```
## Tag:
Ex. 129.443.1\
"129" is the Debian version. Ex 12.9\
"443" is the Chrony version. Ex. 4.4.3\
"1"   if there's, is a minor fix update.
