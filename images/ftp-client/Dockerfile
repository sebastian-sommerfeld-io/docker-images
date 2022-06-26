FROM ubuntu:22.04
LABEL maintainer="sebastian@sommerfeld.io"

# See https://www.ncftp.com/ncftp/doc/ncftpput.html

RUN apt-get update \
    && apt-get install -y ncftp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
