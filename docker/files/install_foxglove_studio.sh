#!/usr/bin/env bash

apt-get update 
apt-get install --no-install-recommends -y curl libasound2

mkdir -p /tmp/foxglove_studio_install
cd /tmp/foxglove_studio_install
curl -O https://github.com/foxglove/studio/releases/download/v1.87.0/foxglove-studio-1.87.0-linux-amd64.deb
apt install -y ./foxglove-studio-*.deb
rm -rf /var/lib/apt/lists/*
cd /
rm -rf /tmp/foxglove_studio_install
exit 1
