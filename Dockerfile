FROM debian:bullseye
LABEL Author=Kerberos.io

RUN apt-get update && apt-get install -y wget build-essential \
    cmake libc-ares-dev uuid-dev daemon libwebsockets-dev

#################################
# Clone and build FFMpeg & OpenCV

RUN apt-get update && apt-get upgrade -y && apt-get -y --no-install-recommends install git cmake wget dh-autoreconf autotools-dev autoconf automake gcc build-essential libtool make ca-certificates supervisor nasm zlib1g-dev tar libx264. unzip wget pkg-config libavresample-dev && \
    git clone https://github.com/FFmpeg/FFmpeg && \
    cd FFmpeg && git checkout n4.4.1 && \
    ./configure --prefix=/usr/local --target-os=linux --enable-nonfree --enable-avfilter --enable-libx264 --enable-gpl --enable-shared && \
    make -j8 && \
    make install && \
    cd .. && rm -rf FFmpeg

RUN	wget -O opencv.zip https://github.com/opencv/opencv/archive/4.5.5.zip && \
    unzip opencv.zip && mv opencv-4.5.5 opencv && cd opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/ \
    -D OPENCV_GENERATE_PKGCONFIG=YES \
    -D BUILD_TESTS=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    #-D BUILD_opencv_dnn=OFF \
    -D BUILD_opencv_ml=OFF \
    -D BUILD_opencv_stitching=OFF \
    -D BUILD_opencv_ts=OFF \
    -D BUILD_opencv_java_bindings_generator=OFF \
    -D BUILD_opencv_python_bindings_generator=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF .. && make -j8 && make install && cd ../.. && rm -rf opencv*

############################
# Build golang

ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

RUN apt-get install -y git
RUN ARCH=$([ "$(uname -m)" = "armv7l" ] && echo "armv6l" || echo "amd64") && wget "https://dl.google.com/go/go1.18.linux-$ARCH.tar.gz" && \
    tar -xvf "go1.18.linux-$ARCH.tar.gz" && \
    mv go /usr/local
