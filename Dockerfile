FROM base-dependencies:latest

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /server

COPY . .

RUN ./tools/ci/run_od.sh

CMD ["./tools/ci/run_server.sh"]
