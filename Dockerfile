FROM ubuntu:22.04 

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y apt-utils software-properties-common tzdata && \
    add-apt-repository multiverse && \
    dpkg --add-architecture i386 && \
    apt update -y && \
    apt upgrade -y 

RUN useradd -m steam && cd /home/steam && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt purge steam steamcmd && \
    apt install -y gdebi-core libgl1-mesa-glx:i386 wget steam steamcmd && \
    ln -s /usr/games/steamcmd /usr/bin/steamcmd

RUN mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources

RUN apt update -y

RUN apt install -y winehq-stable winbind xvfb jq lib32gcc-s1 unzip

RUN rm -rf /var/lib/apt/lists/* && \
    apt clean && \
    apt autoremove -y

COPY run_server.sh /run_server.sh
RUN chmod +x /run_server.sh
CMD ["/run_server.sh"]
