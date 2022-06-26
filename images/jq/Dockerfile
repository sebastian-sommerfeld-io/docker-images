FROM ubuntu:22.04
LABEL maintainer="sebastian@sommerfeld.io"

RUN apt-get update \
    && apt-get install -y jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
