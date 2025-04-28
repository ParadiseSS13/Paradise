FROM node:slim AS tgui
WORKDIR /tgui
COPY /tgui /tgui
RUN bin/tgui

FROM bitnami/dotnet AS dme
WORKDIR /server
COPY . /server
RUN wget https://github.com/OpenDreamProject/OpenDream/releases/download/latest/DMCompiler_linux-x64.tar.gz && \
	tar -xf DMCompiler_linux-x64.tar.gz
RUN dotnet DMCompiler_linux-x64/DMCompiler.dll --suppress-unimplemented --version=515.1633 paradise.dme

FROM ubuntu:latest AS byond
RUN apt-get update && apt-get install -y \
	curl \
	unzip \
	make \
	&& rm -rf /var/lib/apt/lists/*
ENV TARGET_MAJOR="515" \
	TARGET_MINOR="1633" \
	SPACEMANDMM_TAG="suite-1.9" \
	NODE_VERSION="20" \
	PYTHON_VERSION="3.11.6" \
	RUSTG_VERSION="v3.4.0-P"
WORKDIR /byond
RUN curl "http://www.byond.com/download/build/${TARGET_MAJOR}/${TARGET_MAJOR}.${TARGET_MINOR}_byond_linux.zip" -o byond.zip && \
	unzip byond.zip && \
	mv byond/* . && \
	rmdir byond && \
	rm byond.zip
RUN make here && \
	echo "$TARGET_MAJOR.$TARGET_MINOR" > "version.txt"

FROM debian:11-slim
RUN dpkg --add-architecture i386 && \
	apt-get update && apt-get install -y \
	libc6:i386 \
	libstdc++6:i386 \
	zlib1g:i386 \
	&& rm -rf /var/lib/apt/lists/*
WORKDIR /byond
COPY --from=byond /byond /byond
ENV BYOND_SYSTEM=/byond \
	PATH=/byond/bin:$PATH \
	LD_LIBRARY_PATH=/byond/bin \
	MANPATH=/byond/man
WORKDIR /server
COPY --from=dme /server /server
COPY --from=tgui /tgui /server/tgui
EXPOSE 8975
