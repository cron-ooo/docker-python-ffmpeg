FROM python:3.9.4-slim-buster
ENV PATH="${PATH}:/root/.poetry/bin" \
    POETRY_CACHE_DIR="/var/cache/pypoetry"
RUN echo 'deb http://security.debian.org/debian-security buster/updates main non-free contrib\ndeb http://deb.debian.org/debian buster-updates main non-free contrib\ndeb http://deb.debian.org/debian buster-backports main non-free contrib\ndeb http://deb.debian.org/debian buster-proposed-updates main non-free contrib\ndeb http://deb.debian.org/debian buster main non-free contrib\ndeb-src http://deb.debian.org/debian buster main non-free contrib' > /etc/apt/sources.list && \
    echo 'Package: *\nPin: release a=buster/updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-backports\nPin-Priority: 500\n\nPackage: *\nPin: release a=buster-proposed-updates\nPin-Priority: 500' > /etc/apt/preferences && \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y apt-src && \
    apt-src update && \
    mkdir -p /usr/local/src/ffmpeg && \
    cd /usr/local/src/ffmpeg && \
    apt-src install ffmpeg && \
    sed -i 's/--enable-sdl2/--enable-sdl2 \\\n        --enable-nonfree \\\n        --enable-cuda \\\n        --enable-libnpp \\\n        --extra-cflags=-I\/usr\/include\/cuda \\\n        --extra-ldflags=-L\/usr\/lib\/x86_64-linux-gnu\/cuda-gdb/' ffmpeg-*/debian/rules && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends curl gnupg2 build-essential make git libcuda1 libnvcuvid1 libnvidia-encode1 curl && \
    wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y ./deb-multimedia-keyring_2016.8.1_all.deb && \
    echo 'deb http://www.deb-multimedia.org buster main non-free' > /etc/apt/sources.list.d/deb-multimedia.list && \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y nv-codec-headers && \
    apt-src build ffmpeg && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y ./ffmpeg_*.deb ./libavutil56_*.deb ./libavfilter7_*.deb ./libavcodec58_*.deb && \
    echo "\nInstalling Node.js:" && \
    curl -fsSL https://deb.nodesource.com/setup_15.x | bash && \
    apt install -y --no-install-recommends nodejs && \
    node --version && \
    npm --version && \
    echo "\nInstalling poetry package manager:" && \
    echo "https://github.com/python-poetry/poetry" && \
    curl -sSL --compressed "https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py" | python3 && \
    poetry --version && \
    apt purge --autoremove -y curl gnupg2 build-essential make git apt-src nv-codec-headers; \
    apt -y autoremove; \
    apt clean -y; \
    npm cache clean --force; \
    rm -rf /usr/local/src/ffmpeg; \
    rm -rf /root/.cache; \
    rm -rf /usr/local/src; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf ${POETRY_CACHE_DIR}; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py2.7; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py3.5; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py3.6; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py3.7; \
    rm -rf /root/.poetry/lib/poetry/_vendor/py3.8
