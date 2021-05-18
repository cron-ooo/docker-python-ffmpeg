# Официальный образ python, обязательно основанный на debian(Debian buster для совместимости с апи библиотек хоста) иначе будут проблемы с ffmpeg, slim чтобы был более лёгким.
FROM python:3.9.5-slim-buster

# Переменная для корректной работы проброса видеокарты в kubernetes
ENV NVIDIA_VISIBLE_DEVICES=all

# Добавляю все официальные репозитории, в том числе и бекпорты, так сделано на хосте, тут делаем так же для совместимости
RUN echo 'deb http://security.debian.org/debian-security buster/updates main non-free contrib\ndeb http://deb.debian.org/debian buster-updates main non-free contrib\ndeb http://deb.debian.org/debian buster-backports main non-free contrib\ndeb http://deb.debian.org/debian buster-proposed-updates main non-free contrib\ndeb http://deb.debian.org/debian buster main non-free contrib\ndeb-src http://deb.debian.org/debian buster main non-free contrib' > /etc/apt/sources.list && \
    # обновляем кеш пакетов
    apt update && \
    # устанавливаем инструмент для сборки ffmpeg
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y apt-src && \
    # Обновляем кеш пакетов исходного кода
    apt-src update && \
    # создаём директорию для сборки пакетов из исходного кода
    mkdir -p /usr/local/src/ffmpeg && \
    # переходим в директоию для скачивания пакетов исходного кода и установки зависимостей сборки
    cd /usr/local/src/ffmpeg && \
    # скачиваем пакеты исходного кода и устанавливаем зависимости
    apt-src install ffmpeg && \
    # добавляем аргументы сборки для того чтобы ffmpeg мог использовать cuda видеокарты
    sed -i 's/--enable-sdl2/--enable-sdl2 --enable-nonfree --enable-cuda --enable-libnpp --extra-cflags=-I\/usr\/include\/cuda --extra-ldflags=-L\/usr\/lib\/x86_64-linux-gnu\/cuda-gdb/' ffmpeg-*/debian/rules && \
    # Устанавлиаем приоритеты репозиториев для выравнивания приоритетов, чтобы пакеты в дефолте устанавливались из backports
    echo 'Package: *\nPin: release a=buster/updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-backports\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-proposed-updates\nPin-Priority: 500' > /etc/apt/preferences && \
    # Обновляем кеш пакетов
    apt update && \
    # Устанавливаем curl и библиотеки которые нам понадобятся для сборки флагов которые добавили выше
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends curl \
    libcuda1 \
    libnvcuvid1 \
    libnvidia-encode1 \
    nvidia-cuda-dev && \
    # Скачиваем пакет для добавления репозиториев deb-multimedia в этих репозиториях лежит nv-codec-headers который понадобится нам для сборки
    curl -O http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb && \
    # Устанавливаем скачанный пакет
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y ./deb-multimedia-keyring_2016.8.1_all.deb && \
    # добавляем репозитории deb-multimedia
    echo 'deb http://www.deb-multimedia.org buster main non-free\ndeb http://www.deb-multimedia.org buster-backports main' > /etc/apt/sources.list.d/deb-multimedia.list || && \
    # обновляем кеш пакетов
    apt update && \
    # Устанавливаем пакет nv-codec-headers
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y nv-codec-headers && \
    # Удаляем репозитории deb-multimedia
    rm /etc/apt/sources.list.d/deb-multimedia.list && \
    # Собираем ffmpeg и вспомогательные пакеты и библиотеки с фильтрами
    apt-src build ffmpeg && \
    # обновляем кеш пакетов
    apt update && \
    # Устанавливаем пакеты в исходный код которых мы внесли правки, зависимости и остальные пакеты дотягиваются с репозиториев debian
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y --allow-downgrades ./ffmpeg_*.deb \
    ./libavutil56_*.deb \
    ./libavfilter7_*.deb \
    ./libavcodec58_*.deb && \
    # Удаляем пакеты которые были использованы для сборки и более не нужны
    apt purge --autoremove -y gnupg2 \
     build-essential \
     make \
     git \
     apt-src \
     nv-codec-headers \
     nvidia-cuda-dev \
     deb-multimedia-keyring \
     bsdmainutils cleancss \
     comerr-dev \
     doxygen \
     flite1-dev \
     frei0r-plugins-dev \
     gir1.2-freedesktop \
     gir1.2-glib-2.0 \
     icu-devtools \
     ladspa-sdk \
     libaom-dev \
     libavc1394-dev \
     libblkid-dev \
     libbs2b-dev \
     libbz2-dev \
     libc-dev-bin \
     libchromaprint-dev \
     libcodec2-dev \
     libcrystalhd-dev \
     libdpkg-perl \
     libdrm-dev \
     libfribidi-dev \
     libgdbm-compat4 \
     libgdk-pixbuf2.0-bin \
     libgif7 \
     libglib2.0-data \
     libgme-dev \
     libgsm1-dev \
     libiec61883-dev \
     libjs-source-map \
     liblensfun-data-v1 \
     liblilv-dev \
     liblzma-dev \
     libmp3lame-dev \
     libmysofa-dev \
     libogg-dev \
     libomxil-bellagio-dev \
     libopenal-dev \
     libopencore-amrnb-dev \
     libopencore-amrwb-dev \
     libopenjp2-7-dev \
     libopus-dev \
     libpthread-stubs0-dev \
     librsvg2-common \
     librubberband-dev \
     libsnappy-dev \
     libsoxr-dev \
     libspeex-dev \
     libvidstab-dev \
     libvo-amrwbenc-dev \
     libvpx-dev \
     libwavpack-dev \
     libwebp-dev \
     libx264-dev \
     libx265-dev \
     libxvidcore-dev \
     nasm \
     node-less \
     python3 \
     curl && \
    # Очищаем кеш локального репозитория извлечённых файлов
    apt clean -y && \
    # Удаляем пакеты исходного кода, зависимости и собранные пакеты
    rm -rf /usr/local/src && \
    # Подчищаем остатки мусора от apt
    rm -rf /var/lib/apt/lists/* && \
    # Удаляем временные файлы
    rm -rf /tmp/*
