FROM factual/docker-base
MAINTAINER Factual Sysops <sysops@factual.com>

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get -q update && \
    apt-get install -y -q git-core wget isc-dhcp-server

COPY ssh_config /root/.ssh/config
COPY run_isc_dhcp.sh /etc/my_init.d/99_isc-dhcp
COPY ext_sync.sh /etc/service/isc-dhcp-sync/run

# Remove sample dhcp config directory/files
RUN rm -rf /etc/dhcp && \
  mkdir -p /var/run/dhcpd /var/log/dhcpd && \
  chown -R dhcpd:dhcpd /var/run/dhcpd /var/run/dhcpd

# Need to check and see if all these ports are needed
# Or if only 67 is needed
# DHCP server
EXPOSE 67/udp
# DHCPv6 server
EXPOSE 547/udp
# DHCP failover protocol
EXPOSE 647
# DHCP failover protocol
EXPOSE 847

CMD [ "/sbin/my_init" ]

