# Dockerfile
# syntax=docker/dockerfile:1

#
# Welcome to the Dockerfile for Paradise Station crew, enjoy your stay!
# For more info, please see: docs/references/docker.md
#

ARG NODE_VERSION=20
ARG RUST_VERSION=1.92
ARG STABLE_BYOND_MAJOR=516
ARG STABLE_BYOND_MINOR=1666

# BYOND Base Image
FROM beestation/byond:${STABLE_BYOND_MAJOR}.${STABLE_BYOND_MINOR} AS base

# Build Rust Dependencies
FROM rust:${RUST_VERSION}-slim-bookworm AS rust-build
ARG RUST_VERSION
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    clang \
    lib32gcc-12-dev \
    mingw-w64 \
    mingw-w64-i686-dev \
    zlib1g-dev:i386 \
    && rm -rf /var/lib/apt/lists/*
RUN rustup target add i686-unknown-linux-gnu
COPY rust rust
WORKDIR /rust
RUN cargo build --release --target "i686-unknown-linux-gnu"

# Build TGUI
FROM base AS tgui-build
ARG NODE_VERSION
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*
COPY tgui tgui
RUN tgui/bin/tgui

# Render NanoMaps
FROM base AS nanomap-build
COPY _maps _maps
COPY code code
COPY icons icons
COPY tools/github-actions tools/github-actions
COPY paradise.dme paradise.dme
RUN tools/github-actions/nanomap-renderer-invoker.sh

# Build paradise.dmb and paradise.rsc
FROM base AS byond-build
COPY . .
COPY --from=nanomap-build /icons/_nanomaps icons/_nanomaps
COPY --from=tgui-build /tgui/public tgui/public
RUN DreamMaker paradise.dme

# Build final Paradise server image
FROM base AS image
COPY _maps _maps
COPY icons icons
COPY strings strings
COPY --from=byond-build /paradise.dmb paradise.dmb
COPY --from=byond-build /paradise.rsc paradise.rsc
COPY --from=nanomap-build /icons/_nanomaps icons/_nanomaps
COPY --from=rust-build /rust/target/i686-unknown-linux-gnu/release/librustlibs.so librustlibs.so
COPY --from=tgui-build /tgui/public tgui/public
VOLUME [ "/config", "/data" ]
ENTRYPOINT [ "DreamDaemon", "paradise.dmb", "-port", "6666", "-trusted", "-close", "-verbose" ]
EXPOSE 6666
