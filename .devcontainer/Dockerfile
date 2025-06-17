FROM ubuntu:latest

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential \
    curl \
    git \
    locales language-pack-en language-pack-en-base \
    && rm -rf /var/lib/apt/lists/*
