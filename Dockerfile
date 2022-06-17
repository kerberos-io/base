FROM debian:bullseye
LABEL Author=Kerberos.io

RUN apt-get update && apt-get install -y wget build-essential \
    cmake libc-ares-dev uuid-dev daemon libwebsockets-dev
