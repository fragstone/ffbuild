FROM ubuntu:16.04
MAINTAINER thomas@fragstein.de

RUN apt-get update && apt-get install -y \
    build-essential \
    git python wget gawk subversion p7zip-full unzip \
    faketime libfaketime libgmp-dev libmpfr-dev libmpc-dev \
    zlib1g-dev ncurses-dev libssl-dev bsdmainutils \
    ca-certificates curl python2.7 libncurses5-dev libssl-dev cmake pkg-config curl \
    tmux sshfs

VOLUME /home
RUN useradd -m -d /home/build -s /bin/bash build
#RUN chown -R build: /home/build
ENV HOME /home/build

COPY files/ssh/authorized_keys /root/.ssh/authorized_keys
RUN mkdir -p /etc/dropbear
RUN chmod -R 0700 /root/.ssh

ENV DEBIAN_FRONTEND noninteractive
COPY files/etc/keyboard /etc/default/keyboard

WORKDIR /home/build
COPY files/make-2016.sh make-2016.sh
COPY files/sites.bash sites.bash
#RUN chmod 755 make-2017-niers.sh
RUN chown -R build: /home/build

RUN cd /tmp && wget https://git.universe-factory.net/libuecc/snapshot/libuecc-6.zip && unzip libuecc-6.zip && cd libuecc-6 && mkdir build && cd build && cmake -D CMAKE_BUILD_TYPE=RELEASE .. && make && make install && cd /tmp && rm -rf libuecc-6.zip libuecc-6 && ldconfig
RUN cd /tmp && wget https://github.com/tcatm/ecdsautils/archive/ab4eda463b4cdbb58136cec171a686fd11694c4e.zip && unzip ab4eda463b4cdbb58136cec171a686fd11694c4e.zip && cd ecdsautils-ab4eda463b4cdbb58136cec171a686fd11694c4e && mkdir build && cd build && cmake -D CMAKE_BUILD_TYPE=RELEASE .. && make && make install && cd /tmp && rm -rf ab4eda463b4cdbb58136cec171a686fd11694c4e.zip ecdsautils-ab4eda463b4cdbb58136cec171a686fd11694c4e

RUN apt -y install dropbear wget curl rsync vim psmisc procps git
EXPOSE 22

CMD ["dropbear", "-RFEmg", "-p", "22"]
