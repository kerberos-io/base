FROM debian:bullseye AS builder
LABEL Author=Kerberos.io

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget build-essential \
    cmake libc-ares-dev uuid-dev daemon libwebsockets-dev git \
    cmake wget dh-autoreconf autotools-dev autoconf automake gcc \
    build-essential libtool make ca-certificates nasm tar unzip wget pkg-config curl

#############################
# Static build x264

RUN git clone https://code.videolan.org/videolan/x264.git && \
    cd x264 && git checkout 0a84d986 && \
    ./configure --prefix=/usr/local --enable-static --enable-pic && \
    make -j8 && \
    make install && \
    cd .. && rm -rf x264

#################################
# Clone and build FFMpeg & OpenCV

RUN git clone https://github.com/FFmpeg/FFmpeg && \
    cd FFmpeg && git checkout n5.0.1 && \
    ./configure --prefix=/usr/local --target-os=linux --enable-nonfree \
    --extra-ldflags="-latomic" \
    --enable-avfilter \
    --disable-zlib \
    --enable-gpl \ 
    --extra-libs=-latomic  \
    --enable-static --disable-shared  && \
    make -j8 && \
    make install && \
    cd .. && rm -rf FFmpeg

###############
# Download Yarn

RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 16.17.0
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN wget https://github.com/yarnpkg/yarn/releases/download/v1.22.19/yarn_1.22.19_all.deb && \
    dpkg -i yarn_1.22.19_all.deb

############################
# Build Golang

ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

RUN ARCH=$(uname -m) && \
    ARCH=$([ "$(uname -m)" = "armv7l" ] && echo "armv6l" || echo $ARCH) && \
    ARCH=$([ "$(uname -m)" = "x86_64" ] && echo "amd64" || echo $ARCH) && \
    ARCH=$([ "$(uname -m)" = "aarch64" ] && echo "arm64" || echo $ARCH) && \
    wget "https://dl.google.com/go/go1.19.linux-$ARCH.tar.gz" && \
    tar -xvf "go1.19.linux-$ARCH.tar.gz" && \
    rm -rf go1.19.linux-$ARCH.tar.gz && \
    mv go /usr/local