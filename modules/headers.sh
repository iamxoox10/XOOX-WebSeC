#!/bin/bash

TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "[!] Usage: ./headers.sh <URL>"
    exit 1
fi

if [[ "$TARGET" != http://* && "$TARGET" != https://* ]]; then
    TARGET="https://$TARGET"
fi

TMP_FILE="/tmp/xoox_headers_$$.txt"

cleanup() {
    rm -f "$TMP_FILE"
}

trap cleanup EXIT

echo "[+] Checking:"
echo "    $TARGET"
echo

curl \
    -k \
    -s \
    -L \
    -D "$TMP_FILE" \
    -o /dev/null \
    --max-time 15 \
    "$TARGET"

echo "========== SECURITY HEADERS =========="
echo

check_header() {

    HEADER="$1"

    if grep -qi "^${HEADER}:" "$TMP_FILE"; then
        VALUE="$(grep -i "^${HEADER}:" "$TMP_FILE" | head -1)"
        echo "[+] $VALUE"
    else
        echo "[-] Missing: $HEADER"
    fi
}

check_header "Content-Security-Policy"
check_header "Strict-Transport-Security"
check_header "X-Content-Type-Options"
check_header "X-Frame-Options"
check_header "Referrer-Policy"
check_header "Permissions-Policy"

echo
echo "========== INFORMATION HEADERS =========="
echo

check_header "Server"
check_header "X-Powered-By"

echo
echo "[+] HTTP security header audit completed."
