FROM factual/docker-base
RUN apt-get -y update && apt-get -y install bind9 git-core wget

RUN rm -rf /etc/bind

ADD ssh_config /root/.ssh/config
ADD run_named.sh /etc/my_init.d/99_named

RUN mkdir -p /var/run/named
RUN mkdir -p /var/log/named/
RUN chown -R bind:bind /var/run/named
RUN chown -R bind:bind /var/log/named


ADD ext_sync.sh /

VOLUME ["/conf"]

EXPOSE 53 53/udp 953
