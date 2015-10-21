FROM factual/docker-base

RUN apt-get -y clean
RUN apt-get -y update
RUN apt-get -y install automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config 
RUN sudo apt-get -y install vsftpd openssh-server


RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git && \
    cd s3fs-fuse && \
    ./autogen.sh && \
    ./configure  && \ 
    make && \
    sudo make install

RUN mkdir -p /home/aws/s3bucket/

ADD s3-fuse.sh /etc/my_init.d/001-s3-fuse.sh

ADD vsftpd.conf /etc/vsftpd.conf

RUN chown root:root /etc/vsftpd.conf

ADD sshd_config /etc/ssh/sshd_config

ADD users.sh /etc/my_init.d/002-users.sh

RUN echo "/usr/sbin/nologin" >> /etc/shells

EXPOSE 21 22 1024-1048
