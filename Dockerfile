
## https://hub.docker.com/_/debian/tags
FROM debian:12.10-slim

## https://github.com/isc-projects/dhcp/tags
ENV dhcpV="isc-dhcp-server=4.4.3-P1-2"

LABEL org.opencontainers.image.authors="rardcode <sak37564@ik.me>"
LABEL Description="Dhcp server based on Debian."

ARG DEBIAN_FRONTEND=noninteractive

ENV DHCP4=1
ENV DHCP6=0

RUN set -xe && \
  : "---------- ESSENTIAL packages INSTALLATION ----------" \
  && apt-get -q -y update \
  && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     apt-utils \
     rsync \
     procps \
  && apt-get -q -y autoremove \
  && apt-get -q -y clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -xe && \
  : "---------- SPECIFIC packages INSTALLATION ----------" \
  && apt-get -q -y update \
  && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     ${dhcpV} \
  && apt-get -q -y autoremove \
  && apt-get -q -y clean \
  && rm -rf /var/lib/apt/lists/*

ADD rootfs /

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/usr/sbin/dhcpd -4 -f -d --no-pid -cf /etc/dhcp/dhcpd.conf -lf /etc/dhcp/dhcpd.leases -user dhcpd -group dhcpd"]
