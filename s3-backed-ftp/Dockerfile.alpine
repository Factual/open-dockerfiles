FROM alpine:3.5

LABEL maintainer="Factual Sysops<sysops@factual.com>" \
      purpose="Testing alpine. Not ready for production!"

ARG BUILD_DEPS="alpine-sdk automake autoconf curl-dev fuse fuse-dev git libcurl libgcc libstdc++ libxml2 libxml2-dev"
ARG CAN_DELETE="alpine-sdk automake autoconf curl-dev fuse-dev git libxml2-dev"
ARG RUN_DEPS="bash curl inotify-tools openssh openssh-sftp-server py-pip supervisor vsftpd"
ARG VERSION="v1.80"

RUN apk add --update --no-cache ${BUILD_DEPS} \
  && git clone https://github.com/s3fs-fuse/s3fs-fuse.git \
  && cd s3fs-fuse \
  && ./autogen.sh \
  && ./configure  \
  && make         \
  && make install \
  && apk del ${CAN_DELETE}

RUN apk add --update --no-cache ${RUN_DEPS} \
  && pip install awscli

RUN addgroup -S supervisor && adduser -S -D -u 9001 -G supervisor supervisor

WORKDIR /home/supervisor

# Copy needed config files to their destinations
COPY vsftpd.conf /etc/vsftpd.conf
COPY sshd_config /etc/ssh/sshd_config
COPY supervisord.conf /home/supervisor/supervisord.conf
COPY [ "s3-fuse.sh", "entrypoint.sh", "add_users_in_container.sh", "/home/supervisor/" ]

# Expose ftp and sftp ports
EXPOSE 21 22

# Run supervisord at container start
ENV MOUNT_POINT /home/aws/s3bucket
ENTRYPOINT [ "/home/supervisor/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord" , "-c", "/home/supervisor/supervisord.conf" ]
