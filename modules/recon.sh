#!/bin/bash

TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "[!] Usage: ./recon.sh <URL>"
    exit 1
fi

if [[ "$TARGET" != http://* && "$TARGET" != https://* ]]; then
    TARGET="https://$TARGET"
fi

echo "[+] Target: $TARGET"
echo

echo "========== HTTP RESPONSE =========="

curl \
    -k \
    -L \
    -I \
    --max-time 15 \
    "$TARGET" 2>/dev/null

echo

echo "========== ROBOTS.TXT =========="

BASE="${TARGET%/}"

curl \
    -k \
    -L \
    --max-time 15 \
    "$BASE/robots.txt" 2>/dev/null | head -100

echo

echo "========== SITEMAP =========="

curl \
    -k \
    -L \
    --max-time 15 \
    "$BASE/sitemap.xml" 2>/dev/null | head -100

echo

echo "========== SERVER INFORMATION =========="

curl \
    -k \
    -s \
    -L \
    -D - \
    -o /dev/null \
    --max-time 15 \
    "$TARGET" 2>/dev/null |
    grep -Ei '^(server|x-powered-by|content-type|location):' || true

echo
echo "[+] Recon completed."
