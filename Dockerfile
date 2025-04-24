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

COPY tools/ci/install_byond.sh /usr/local/bin/install_byond.sh
COPY _build_dependencies.sh /usr/local/bin/_build_dependencies.sh
COPY Dockerfile.env /usr/local/bin/Dockerfile.env

RUN chmod +x /usr/local/bin/install_byond.sh && \
	. /usr/local/bin/Dockerfile.env && \
	/usr/local/bin/install_byond.sh

WORKDIR /server
COPY . /server

RUN . $HOME/BYOND/byond/bin/byondsetup
RUN npm install yarn
RUN ./tgui/bin/tgui --ci
run echo $PATH

RUN DreamMaker -DMULTIINSTANCE -DCIMAP -DPARADISE_PRODUCTION_HARDWARE paradise.dme

CMD ["DreamDaemon", "paradise.dmb", "-port", "1337", "-trusted"]
