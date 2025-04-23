# Используем базовый образ Ubuntu
FROM ubuntu:20.04

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Устанавливаем зависимости
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    build-essential \
    python3 \
    python3-pip \
    git \
    nodejs \
    npm \
    default-jre \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем unzip для распаковки архивов
RUN apt-get update && apt-get install -y unzip

# Устанавливаем BYOND и используем DreamMaker для компиляции
RUN wget https://www.byond.com/download/build/514/514.1588_byond_linux.zip \
    && unzip 514.1588_byond_linux.zip -d /tmp/byond \
    && mv /tmp/byond/byond /opt/byond \
    && rm -rf /tmp/byond 514.1588_byond_linux.zip

# Добавляем BYOND в PATH
ENV PATH="/opt/byond/bin:$PATH"

# Устанавливаем рабочую директорию
WORKDIR /server

# Копируем файлы проекта
COPY . /server

# Устанавливаем yarn для управления зависимостями
RUN npm install -g yarn

# Используем встроенный скрипт для сборки TGUI в режиме CI
WORKDIR /server/tgui
RUN ./bin/tgui --ci

# Возвращаемся в корневую директорию
WORKDIR /server

# Компилируем проект с использованием DreamMaker
RUN DreamMaker -DMULTIINSTANCE -DCIMAP -DPARADISE_PRODUCTION_HARDWARE paradise.dme

# Указываем команду для запуска сервера
CMD ["DreamDaemon", "paradise.dmb", "-port", "1337", "-trusted"]
