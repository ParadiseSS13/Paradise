FROM node:slim

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    make \
    python3 \
    python3-pip \
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    libc6:i386 libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386 \
    && rm -rf /var/lib/apt/lists/*

COPY Dockerfile.env /usr/local/bin/Dockerfile.env
RUN . /usr/local/bin/Dockerfile.env

COPY tools/ci/ /usr/local/bin/
COPY _build_dependencies.sh /usr/local/bin/_build_dependencies.sh
RUN /usr/local/bin/install_byond.sh

WORKDIR /server
COPY . /server

RUN . $HOME/BYOND/byond/bin/byondsetup
RUN npm install yarn
RUN ./tgui/bin/tgui --ci

RUN DreamMaker -DMULTIINSTANCE -DCIMAP -DPARADISE_PRODUCTION_HARDWARE paradise.dme

CMD ["/usr/local/bin/run_server.sh"]
