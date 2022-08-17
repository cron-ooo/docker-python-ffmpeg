# Официальный образ python, обязательно основанный на debian(Debian buster для совместимости с апи библиотек хоста) иначе будут проблемы с ffmpeg, slim чтобы был более лёгким.
FROM python:3.10.4-slim-bullseye

# Добавляю все официальные репозитории, в том числе и бекпорты, так сделано на хосте, тут делаем так же для совместимости
RUN echo 'deb http://security.debian.org/debian-security bullseye-security main non-free contrib\ndeb http://deb.debian.org/debian bullseye-updates main non-free contrib\ndeb http://deb.debian.org/debian bullseye main non-free contrib\ndeb http://deb.debian.org/debian bullseye-backports-sloppy main non-free contrib\ndeb http://deb.debian.org/debian bullseye-backports main non-free contrib\ndeb http://deb.debian.org/debian bullseye-proposed-updates main non-free contrib' > /etc/apt/sources.list && \
    # Устанавлиаем приоритеты репозиториев для выравнивания приоритетов, чтобы пакеты в дефолте устанавливались из backports
    echo 'Package: *\nPin: release a=bullseye-security\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye-updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye-backports-sloppy\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye-backports\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye-proposed-updates\nPin-Priority: 500' > /etc/apt/preferences && \
    # Обновляем кеш пакетов
    apt update && \
    # Устанавливаем curl
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends curl && \
    # Скачиваем пакет для добавления репозиториев deb-multimedia в этих репозиториях лежит nv-codec-headers который понадобится нам для сборки
    curl -O http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb && \
    # Устанавливаем скачанный пакет
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y ./deb-multimedia-keyring_2016.8.1_all.deb && \
    # добавляем репозитории deb-multimedia
    echo 'deb http://www.deb-multimedia.org bullseye main non-free\ndeb http://www.deb-multimedia.org bullseye-backports main' > /etc/apt/sources.list.d/deb-multimedia.list && \
    # обновляем кеш пакетов
    apt update && \
    # Устанавливаем пакеты в исходный код которых мы внесли правки, зависимости и остальные пакеты дотягиваются с репозиториев debian
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y --allow-downgrades ffmpeg \
     libcuda1 \
     libnvcuvid1 \
     libnvidia-encode1 \
     opencl-headers \
     nvidia-opencl-icd && \
    # Удаляем curl
    apt purge -y curl && \
    apt autoremove -y && \
    apt autoclean -y && \
    # Очищаем кеш локального репозитория извлечённых файлов
    apt clean -y && \
    # Подчищаем остатки мусора от apt
    rm -rf /var/lib/apt/lists/* && \
    # Удаляем временные файлы
    rm -rf /tmp/*
# Переменная для корректной работы проброса видеокарты в kubernetes
ENV NVIDIA_VISIBLE_DEVICES=all
