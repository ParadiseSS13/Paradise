# Dockerfile
# syntax=docker/dockerfile:1

#
# Welcome to the Dockerfile for Paradise Station crew, enjoy your stay!
# For more info, please see: docs/references/docker.md
#

# You MUST supply these to `docker build` with a `--build-arg` flag!
ARG NODE_VERSION=0
ARG RUST_VERSION=0
ARG STABLE_BYOND_MAJOR=0
ARG STABLE_BYOND_MINOR=0

# Gate: Were we supplied with all the required --build-arg flags?
FROM ubuntu:24.04 AS build-dependencies
# Required build arguments
ARG NODE_VERSION
ARG RUST_VERSION
ARG STABLE_BYOND_MAJOR
ARG STABLE_BYOND_MINOR
# Optional build metadata
ARG VCS_REF
ARG BUILD_DATE
# Verify and record all required arguments
RUN [ "$NODE_VERSION" != "0" ] || { echo "\n\n--build-arg=NODE_VERSION=??? must be supplied\n\n"; exit 2; };
RUN [ "$RUST_VERSION" != "0" ] || { echo "\n\n--build-arg=RUST_VERSION=??? must be supplied"; exit 2; };
RUN [ "$STABLE_BYOND_MAJOR" != "0" ] || { echo "\n\n--build-arg=STABLE_BYOND_MAJOR=??? must be supplied"; exit 2; };
RUN [ "$STABLE_BYOND_MINOR" != "0" ] || { echo "\n\n--build-arg=STABLE_BYOND_MINOR=??? must be supplied"; exit 2; };
RUN { echo "# Generated at image build time. Do not edit."; \
    [ -n "${BUILD_DATE:-}" ] && echo "BUILD_DATE=$BUILD_DATE" || true; \
    [ -n "${VCS_REF:-}" ] && echo "VCS_REF=$VCS_REF" || true; \
    echo "NODE_VERSION=$NODE_VERSION"; \
    echo "RUST_VERSION=$RUST_VERSION"; \
    echo "STABLE_BYOND_MAJOR=$STABLE_BYOND_MAJOR"; \
    echo "STABLE_BYOND_MINOR=$STABLE_BYOND_MINOR"; \
    echo "BYOND_IMAGE=beestation/byond:${STABLE_BYOND_MAJOR}.${STABLE_BYOND_MINOR}"; \
    echo "RUST_IMAGE=rust:${RUST_VERSION}-slim-bookworm"; \
    } > /_built_as.env

# --- Mission Specifications Decrypted: Welcome to the Syndicate...

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
FROM ubuntu:24.04 AS nanomap-build
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
COPY _build_dependencies.sh _build_dependencies.sh
COPY _maps _maps
COPY icons icons
COPY strings strings
COPY --from=build-dependencies /_built_as.env _built_as.env
COPY --from=byond-build /paradise.dmb paradise.dmb
COPY --from=byond-build /paradise.rsc paradise.rsc
COPY --from=nanomap-build /icons/_nanomaps icons/_nanomaps
COPY --from=rust-build /rust/target/i686-unknown-linux-gnu/release/librustlibs.so librustlibs.so
COPY --from=tgui-build /tgui/public tgui/public
VOLUME [ "/config", "/data" ]
ENTRYPOINT [ "DreamDaemon", "paradise.dmb", "-port", "6666", "-trusted", "-close", "-verbose" ]
EXPOSE 6666
