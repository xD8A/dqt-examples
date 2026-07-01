FROM ghcr.io/tom-tan/ldc:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install packages and headers required to build Qt from source
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    cmake \
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
    && rm -rf /var/lib/apt/lists/*

# Download the Qt 6.4.2 source tarball
WORKDIR /opt
RUN wget https://download.qt.io/archive/qt/6.4/6.4.2/single/qt-everywhere-src-6.4.2.tar.xz \
    && tar -xvf qt-everywhere-src-6.4.2.tar.xz \
    && rm qt-everywhere-src-6.4.2.tar.xz

# Configure, build and install Qt 6.4.2 with XCB support (skip examples and tests to speed up)
RUN cd qt-everywhere-src-6.4.2 \
    && ./configure -prefix /opt/qt-6.4.2 -release -nomake examples -nomake tests -xcb \
    && make -j$(nproc) \
    && make install \
    && cd .. && rm -rf qt-everywhere-src-6.4.2

# Make Qt shared libraries and pkg-config files discoverable
ENV LD_LIBRARY_PATH=/opt/qt-6.4.2/lib:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=/opt/qt-6.4.2/lib/pkgconfig:$PKG_CONFIG_PATH
