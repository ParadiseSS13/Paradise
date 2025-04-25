FROM ubuntu:latest AS base
WORKDIR /server
COPY . .

FROM node:slim AS tgui
WORKDIR /server/tgui
COPY --from=base /server/tgui /server/tgui
RUN bin/tgui

FROM bitnami/dotnet AS dme
WORKDIR /server
COPY --from=base /server /server
RUN wget https://github.com/OpenDreamProject/OpenDream/releases/download/latest/DMCompiler_linux-x64.tar.gz && \
	tar -xf DMCompiler_linux-x64.tar.gz
RUN dotnet DMCompiler_linux-x64/DMCompiler.dll --suppress-unimplemented --version=515.1633 paradise.dme

FROM debian:11-slim AS byond
RUN dpkg --add-architecture i386 && \
	apt-get update && apt-get install -y \
	curl \
	wget \
	git \
	unzip \
	make \
	python3 \
	python3-pip \
	rustc \
	cargo \
	libc6:i386 \
	libstdc++6:i386 \
	libgcc1:i386 \
	zlib1g:i386 \
	libncurses5:i386 \
	apt-transport-https \
	&& rm -rf /var/lib/apt/lists/*
ENV TARGET_MAJOR="515" \
	TARGET_MINOR="1633" \
	SPACEMANDMM_TAG="suite-1.9" \
	NODE_VERSION="20" \
	PYTHON_VERSION="3.11.6" \
	RUSTG_VERSION="v3.4.0-P"
WORKDIR /server/byond
RUN curl "http://www.byond.com/download/build/${TARGET_MAJOR}/${TARGET_MAJOR}.${TARGET_MINOR}_byond_linux.zip" -o byond.zip && \
	unzip byond.zip && \
	mv byond/* . && \
	rmdir byond && \
	rm byond.zip
RUN make here && \
	. bin/byondsetup && \
	echo "$TARGET_MAJOR.$TARGET_MINOR" > "version.txt"

FROM ubuntu:latest
WORKDIR /server
COPY --from=base /server /server
COPY --from=tgui /server/tgui /server/tgui
COPY --from=byond /server/byond /server/byond
COPY --from=dme /server/paradise.dme /server/paradise.dme
RUN . byond/bin/byondsetup
EXPOSE 8975
