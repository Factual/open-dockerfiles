FROM factual/docker-base
RUN apt-get -y update && apt-get -y install bind9 git-core wget

RUN rm -rf /etc/bind

ADD ssh_config /root/.ssh/config
ADD run_named.sh /etc/my_init.d/99_named

RUN mkdir /etc/service/ext_sync
RUN mkdir -p /var/run/named

RUN chown -R bind:bind /var/run/named

ADD ext_sync.sh /etc/service/ext_sync/run

VOLUME ["/conf"]

EXPOSE 53 953
