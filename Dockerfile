FROM ubuntu:22.04

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt update -y

# Common dependencies
RUN apt install -y apt-utils software-properties-common wget && \
    add-apt-repository multiverse && \
    dpkg --add-architecture i386 && \
    apt update -y && \
    apt upgrade -y

# Install Steam
RUN useradd -m steam && cd /home/steam && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt install -y steam steamcmd && \
    ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Install Wine
RUN apt install -y gdebi-core libgl1-mesa-glx:i386
RUN apt install -y wine winbind winetricks
RUN apt install -y xvfb xserver-xorg

RUN rm -rf /var/lib/apt/lists/* && \
    apt clean && \
    apt autoremove -y

COPY run_server.sh /run_server.sh
RUN chmod +x /run_server.sh

CMD ["/run_server.sh"]
