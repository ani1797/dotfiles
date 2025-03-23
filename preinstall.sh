#!/usr/bin/env bash

apt-get update \
    && apt-get -y -qq --no-install-recommends install build-essential ca-certificates git curl zsh gcc 2>&1 \
    && apt-get -y -qq clean \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*
