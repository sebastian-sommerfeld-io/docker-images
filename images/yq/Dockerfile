FROM ubuntu:22.04
LABEL maintainer="sebastian@sommerfeld.io"

ENV VERSION="v4.2.0"
ENV BINARY="yq_linux_amd64"

RUN apt-get update \
    && apt-get install -y curl \
    && curl -sL https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz | tar xz && mv ${BINARY} /usr/bin/yq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
