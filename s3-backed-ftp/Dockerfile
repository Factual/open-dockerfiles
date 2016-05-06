FROM debian:jessie

# Install needed build packages and cleanup after
RUN buildDeps='automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config' \
  && runDeps='python3-pip vsftpd openssh-server supervisor' \
  && apt-get -y update && apt-get -y install $buildDeps $runDeps --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && git clone https://github.com/s3fs-fuse/s3fs-fuse.git \
  && cd s3fs-fuse \
  && ./autogen.sh \
  && ./configure  \
  && make \
  && make install \
  && apt-get purge -y --auto-remove $buildDeps \
  && pip3 install awscli \
  && mkdir -p /home/aws/s3bucket/ \
  && echo "/usr/sbin/nologin" >> /etc/shells

# Copy scripts to /usr/local
COPY [ "s3-fuse.sh", "users.sh", "add_users_in_container.sh", "/usr/local/" ]

# Copy needed config files to their destinations
COPY vsftpd.conf /etc/vsftpd.conf
COPY sshd_config /etc/ssh/sshd_config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ftp and sftp ports
EXPOSE 21 22

# Run supervisord at container start
CMD [ "/usr/bin/supervisord" ]

