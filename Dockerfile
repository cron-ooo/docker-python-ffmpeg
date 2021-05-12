FROM python:3.9.5-slim-buster
ENV PATH="${PATH}:/root/.poetry/bin" \
    POETRY_CACHE_DIR="/var/cache/pypoetry" \
    NODE_VERSION=16.1.0
RUN echo 'deb http://security.debian.org/debian-security buster/updates main non-free contrib\ndeb http://deb.debian.org/debian buster-updates main non-free contrib\ndeb http://deb.debian.org/debian buster-backports main non-free contrib\ndeb http://deb.debian.org/debian buster-proposed-updates main non-free contrib\ndeb http://deb.debian.org/debian buster main non-free contrib\ndeb-src http://deb.debian.org/debian buster main non-free contrib' > /etc/apt/sources.list || exit 1 && \
    apt update || exit 1 && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y apt-src || exit 1 && \
    apt-src update || exit 1 && \
    mkdir -p /usr/local/src/ffmpeg || exit 1 && \
    cd /usr/local/src/ffmpeg || exit 1 && \
    apt-src install ffmpeg || exit 1 && \
    sed -i 's/--enable-sdl2/--enable-sdl2 \\\n        --enable-nonfree \\\n        --enable-cuda \\\n        --enable-libnpp \\\n        --extra-cflags=-I\/usr\/include\/cuda \\\n        --extra-ldflags=-L\/usr\/lib\/x86_64-linux-gnu\/cuda-gdb/' ffmpeg-*/debian/rules || exit 1 && \
    echo 'Package: *\nPin: release a=buster/updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-backports\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-proposed-updates\nPin-Priority: 500' > /etc/apt/preferences || exit 1 && \
    apt update || exit 1 && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends curl gnupg2 build-essential make git libcuda1 libnvcuvid1 libnvidia-encode1 nvidia-cuda-dev || exit 1 && \
    curl -O http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb || exit 1 && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y ./deb-multimedia-keyring_2016.8.1_all.deb || exit 1 && \
    echo 'deb http://www.deb-multimedia.org buster main non-free\ndeb http://www.deb-multimedia.org buster-backports main' > /etc/apt/sources.list.d/deb-multimedia.list || exit 1 && \
    apt update || exit 1 && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y nv-codec-headers || exit 1 && \
    rm /etc/apt/sources.list.d/deb-multimedia.list || exit 1 && \
    apt-src build ffmpeg || exit 1 && \
    apt update || exit 1 && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y --allow-downgrades ./ffmpeg_*.deb ./libavutil56_*.deb ./libavfilter7_*.deb ./libavcodec58_*.deb || exit 1 && \
    curl -sSLO --compressed "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" || exit 1 && \
    tar -xJf "node-v${NODE_VERSION}-linux-x64.tar.xz" -C "/usr/local" --strip-components=1 --no-same-owner || exit 1 && \
    npm i -g npm@7.11.2 || exit 1 && \
    rm "node-v${NODE_VERSION}-linux-x64.tar.xz" || exit 1 && \
    apt purge --autoremove -y gnupg2 build-essential make git apt-src nv-codec-headers nvidia-cuda-dev deb-multimedia-keyring bsdmainutils cleancss comerr-dev doxygen flite1-dev frei0r-plugins-dev gir1.2-freedesktop gir1.2-glib-2.0 icu-devtools ladspa-sdk libaom-dev libavc1394-dev libblkid-dev libbs2b-dev libbz2-dev libc-dev-bin libchromaprint-dev libcodec2-dev libcrystalhd-dev libdpkg-perl libdrm-dev libfribidi-dev libgdbm-compat4 libgdk-pixbuf2.0-bin libgif7 libglib2.0-data libgme-dev libgsm1-dev libiec61883-dev libjs-source-map liblensfun-data-v1 liblilv-dev liblzma-dev libmp3lame-dev libmysofa-dev libogg-dev libomxil-bellagio-dev libopenal-dev libopencore-amrnb-dev libopencore-amrwb-dev libopenjp2-7-dev libopus-dev libpthread-stubs0-dev librsvg2-common librubberband-dev libsnappy-dev libsoxr-dev libspeex-dev libvidstab-dev libvo-amrwbenc-dev libvpx-dev libwavpack-dev libwebp-dev libx264-dev libx265-dev libxvidcore-dev nasm node-less python3; \
    curl -sSL --compressed "https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py" | python || exit 1 && \
    apt purge --autoremove -y curl; \
    poetry --version || exit 1 && \
    apt -y autoremove; \
    apt clean -y; \
    npm cache clean --force; \
    rm -rf /root/.cache; \
    rm -rf /usr/local/src; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf ${POETRY_CACHE_DIR}; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py2.7; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py3.5; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py3.6; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py3.7; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py3.8; \
    rm -rf /tmp/*
