FROM debian:bookworm
LABEL Author=Kerberos.io

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget build-essential \
    cmake libc-ares-dev uuid-dev daemon libwebsockets-dev git \
    cmake wget dh-autoreconf autotools-dev autoconf automake gcc \
    build-essential libtool make ca-certificates libc6 supervisor nasm \
    zlib1g-dev tar unzip wget pkg-config

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
    cd FFmpeg && git checkout n4.4.1 && \
    ./configure --prefix=/usr/local --target-os=linux --enable-nonfree \
    --extra-ldflags="-latomic" \
    --enable-avfilter \
    --enable-avresample \
    --enable-libx264 \
    --enable-gpl \ 
    --extra-libs=-latomic  \
    --enable-static --disable-shared  && \
    make -j8 && \
    make install && \
    cd .. && rm -rf FFmpeg

#RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.7.0.zip && \
#    unzip opencv.zip && mv opencv-4.7.0 opencv && cd opencv && mkdir build && cd build && \
#    cmake -D CMAKE_BUILD_TYPE=RELEASE \
#    -D CMAKE_INSTALL_PREFIX=/usr/ \
#    -D OPENCV_GENERATE_PKGCONFIG=YES \
#    -D BUILD_SHARED_LIBS=OFF \
#    -D BUILD_TESTS=OFF \
#    -D OPENCV_ENABLE_NONFREE=ON \
#    #-D BUILD_opencv_dnn=OFF \
#    -D BUILD_opencv_ml=OFF \
#    -D BUILD_opencv_stitching=OFF \
#    -D BUILD_opencv_ts=OFF \
#    -D BUILD_opencv_java_bindings_generator=OFF \
#    -D BUILD_opencv_python_bindings_generator=OFF \
#    -D INSTALL_PYTHON_EXAMPLES=OFF \
#    -D BUILD_EXAMPLES=OFF .. && make -j8 && make install && cd ../.. && rm -rf opencv*

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
