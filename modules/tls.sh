#!/bin/bash

TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "[!] Usage: ./tls.sh <URL>"
    exit 1
fi

HOST="$TARGET"

HOST="${HOST#https://}"
HOST="${HOST#http://}"
HOST="${HOST%%/*}"

PORT="443"

if [[ "$HOST" == *:* ]]; then
    POSSIBLE_PORT="${HOST##*:}"

    if [[ "$POSSIBLE_PORT" =~ ^[0-9]+$ ]]; then
        PORT="$POSSIBLE_PORT"
        HOST="${HOST%:*}"
    fi
fi

echo "[+] TLS target: $HOST:$PORT"
echo

if ! command -v openssl >/dev/null 2>&1; then
    echo "[!] OpenSSL is not installed."
    exit 1
fi

echo "========== CERTIFICATE =========="

openssl s_client \
    -connect "$HOST:$PORT" \
    -servername "$HOST" \
    </dev/null 2>/dev/null |
openssl x509 \
    -noout \
    -subject \
    -issuer \
    -dates \
    -serial

echo

echo "========== TLS CONNECTION =========="

openssl s_client \
    -connect "$HOST:$PORT" \
    -servername "$HOST" \
    -brief \
    </dev/null 2>&1 |
head -30

echo
echo "[+] TLS audit completed."
