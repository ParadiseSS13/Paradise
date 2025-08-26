FROM --platform=linux/amd64 node:slim AS tgui
WORKDIR /tgui
COPY /tgui /tgui
RUN bin/tgui

FROM bitnami/dotnet AS dme
WORKDIR /server
COPY . /server
RUN curl -O -L https://github.com/OpenDreamProject/OpenDream/releases/download/latest/DMCompiler_linux-x64.tar.gz && \
	tar -xf DMCompiler_linux-x64.tar.gz
RUN dotnet DMCompiler_linux-x64/DMCompiler.dll --suppress-unimplemented --version=516.1666 paradise.dme

FROM ubuntu:latest AS byond
RUN apt-get update && apt-get install -y \
	curl \
	unzip \
	make \
	&& rm -rf /var/lib/apt/lists/*
ENV TARGET_MAJOR="516" \
	TARGET_MINOR="1666" \
	SPACEMANDMM_TAG="suite-1.10" \
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

FROM bitnami/dotnet
WORKDIR /server
COPY --from=dme /server /server
COPY --from=tgui /tgui/public /server/tgui/public
RUN curl -O -L https://github.com/OpenDreamProject/OpenDream/releases/download/latest/OpenDreamServer_linux-x64.tar.gz && \
	tar -xf OpenDreamServer_linux-x64.tar.gz
RUN dotnet DMCompiler_linux-x64/Robust.Server.dll --version=516.1666 paradise.dme
