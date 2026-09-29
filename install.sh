#!/bin/bash

set -e

echo
echo "========================================"
echo "       XOOX WebSeC Installer"
echo "========================================"
echo

echo "[*] Updating package repositories..."
apk update

echo
echo "[*] Installing dependencies..."

apk add \
    bash \
    curl \
    wget \
    openssl \
    nmap \
    ca-certificates \
    coreutils \
    grep \
    sed \
    gawk

echo
echo "[*] Setting permissions..."

chmod +x xox
chmod +x install.sh
chmod +x modules/*.sh

mkdir -p reports

echo
echo "========================================"
echo " Installation completed successfully"
echo "========================================"
echo
echo "Run:"
echo
echo "    ./xox"
echo
