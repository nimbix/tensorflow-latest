#!/usr/bin/env bash

set -e
# Build python 3.12

DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    git \
    libexpat1-dev \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    libsqlite3-dev \
    libffi-dev \
    tcl-dev \
    linux-headers-generic \
    libgdbm-dev \
    libreadline-dev \
    tk \
    tk-dev \
    wget

WORK_DIR=/tmp/$(mktemp -d)
mkdir -p $WORK_DIR
cd $WORK_DIR
wget https://www.python.org/ftp/python/3.12.12/Python-3.12.12.tgz
tar xf Python-3.12.12.tgz
rm Python-3.12.12.tgz
cd Python-3.12.12
mkdir BUILD
cd BUILD
../configure --enable-optimizations --with-lto=full --with-ensurepip=install
make -j8
make install
cd /tmp
rm -rf $WORK_DIR
