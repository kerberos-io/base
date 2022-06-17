FROM debian:bullseye
LABEL Author=Kerberos.io

RUN apt-get update && apt-get install -y wget build-essential \
    cmake libc-ares-dev uuid-dev daemon libwebsockets-dev

############################
# Build golang

ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

RUN apt-get install -y git

RUN ARCH=$([ "$(uname -m)" = "armv7l" ] && echo "armv6l" || echo "$(uname -m)") && wget "https://dl.google.com/go/go1.18.linux-$ARCH.tar.gz" && \
    tar -xvf "go1.18.linux-$ARCH.tar.gz" && \
    mv go /usr/local


