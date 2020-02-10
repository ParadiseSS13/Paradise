FROM i386/ubuntu:bionic as base_config
ENV BYOND_MAJOR=512 \
    BYOND_MINOR=1488 \
    RUST_G_VERSION=0.2.0
    

FROM base_config as byond
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    make \
    && curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip \
    && unzip byond.zip \
    && cd byond \
    && sed -i 's|install:|&\n\tmkdir -p $(MAN_DIR)/man6|' Makefile \
    && make install \
    && chmod 644 /usr/local/byond/man/man6/* \
    && apt-get purge -y --auto-remove curl unzip make \
    && cd .. \
    && rm -rf byond byond.zip


FROM base_config as rust_g
WORKDIR /rust_g
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    libssl-dev \
    pkg-config \
    curl \
    gcc-multilib \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y \
    && git init \
    && git remote add origin https://github.com/ParadiseSS13/rust-g
RUN git fetch --depth 1 origin "${RUST_G_VERSION}" \
    && git checkout FETCH_HEAD \
    && ~/.cargo/bin/cargo build --release



FROM base_config as paradise_build
WORKDIR /paradise
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libmysqlclient20 \
    libssl1.0.0
RUN apt-get autoremove
RUN rm -rf /var/lib/apt/lists/*
RUN cp /usr/lib/i386-linux-gnu/libmysqlclient.so.20 /usr/lib/libmariadb.so
COPY --from=byond /usr/local/byond/bin/DreamMaker /usr/local/bin
COPY --from=byond /usr/local/byond/bin/DreamDaemon /usr/local/bin
COPY --from=byond /usr/local/byond/bin/*.so /usr/lib/
COPY --from=rust_g /rust_g/target/release/librust_g.so .
COPY . .
RUN DreamMaker -max_errors 0 paradise.dme
RUN mv config defaultconfig
RUN chmod a+x docker-entrypoint.sh


FROM scratch
WORKDIR /paradise
COPY --from=paradise_build / /
VOLUME [ "/paradise/config", "/paradise/data" ]
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD [ "DreamDaemon", "paradise.dmb", "-port", "6666", "-trusted", "-close", "-verbose" ]

EXPOSE 6666
