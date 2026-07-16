FROM ghcr.io/tom-tan/ldc:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install packages and headers required to build Qt from source
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    cmake \
    git \
    ninja-build \
    gperf \
    pkg-config \
    bison \
    flex \
    python3 \
    python3-pip \
    python3-html5lib \
    nodejs \
    npm \
    libgl1-mesa-dev \
    libxcb-cursor-dev \ 
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-shape0-dev \
    libxcb-util-dev \
    libxcb-xfixes0-dev \
    libxcb-xinerama0-dev \
    libxcb-xinput-dev \
    libxcb-xkb-dev \
    libxcb-glx0-dev \
    libxcb-composite0-dev \
    libxcb-damage0-dev \
    libxcb-present-dev \
    libxcb-shm0-dev \
    libxcb-sync-dev \
    libxcb-xv0-dev \
    libxcb-xtest0-dev \
    libxcb-record0-dev \
    libxcb-dri2-0-dev \
    libxcb-dri3-dev \
    libx11-xcb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libinput-dev \
    libxshmfence-dev \
    libxxf86vm-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libssl-dev \
    libnss3-dev \
    libglib2.0-dev \
    libdrm-dev \
    libxkbfile-dev \
    libpulse-dev \
    libdbus-1-dev \
    libevent-dev \
    libxml2-dev \
    libxslt1-dev \
    liblcms2-dev \
    libminizip-dev \
    libre2-dev \
    libpci-dev \
    libwebp-dev \
    libopus-dev \
    libvpx-dev \
    libsnappy-dev \
    libxcomposite-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxi-dev \
    libxtst-dev \
    && rm -rf /var/lib/apt/lists/*

# Extract Qt 6.4.2 source archives from host directory
WORKDIR /opt
RUN --mount=type=bind,source=downloads,target=/opt/downloads,ro,Z \
    tar -xvf /opt/downloads/qt-everywhere-src-6.4.2.tar.xz \
    && tar -xvf /opt/downloads/qtwebengine-everywhere-src-6.4.2.tar.xz \
    && mv qtwebengine-everywhere-src-6.4.2 qt-everywhere-src-6.4.2/qtwebengine

# Build and install Qt 6.4.2 with XCB, Pdf, and WebEngine
WORKDIR /opt/qt-everywhere-src-6.4.2
RUN ./configure -prefix /opt/qt-6.4.2 -release -nomake examples -nomake tests \
        -xcb \
        -skip qtdoc \
    && cmake --build . --parallel \
    && cmake --install . \
    && cd .. && rm -rf /opt/qt-everywhere-src-6.4.2

WORKDIR /opt

# Make Qt shared libraries and pkg-config files discoverable
ENV LD_LIBRARY_PATH=/opt/qt-6.4.2/lib:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=/opt/qt-6.4.2/lib/pkgconfig:$PKG_CONFIG_PATH
