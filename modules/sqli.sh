#!/bin/bash

TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "[!] Usage: ./sqli.sh 'https://example.com/page?id=1'"
    exit 1
fi

if [[ "$TARGET" != http://* && "$TARGET" != https://* ]]; then
    TARGET="https://$TARGET"
fi

echo "[+] Target:"
echo "    $TARGET"
echo

if [[ "$TARGET" != *"?"* ]]; then
    echo "[!] No query parameters detected."
    echo
    echo "Example:"
    echo "    https://example.com/page?id=1"
    exit 0
fi

QUERY="${TARGET#*\?}"

echo "========== PARAMETERS =========="
echo

IFS='&' read -ra PARAMS <<< "$QUERY"

FOUND=0

for PARAM in "${PARAMS[@]}"; do

    NAME="${PARAM%%=*}"

    if [ -n "$NAME" ]; then
        echo "[+] Parameter: $NAME"
        FOUND=$((FOUND + 1))
    fi

done

echo
echo "Parameters found: $FOUND"
echo

echo "========== RESPONSE ERROR CHECK =========="
echo

RESPONSE="$(curl \
    -k \
    -L \
    -s \
    --max-time 15 \
    "$TARGET" 2>/dev/null)"

if [ -z "$RESPONSE" ]; then
    echo "[!] Empty response or request failed."
    exit 1
fi

ERRORS=0

check_error() {

    PATTERN="$1"

    if printf '%s' "$RESPONSE" | grep -Eiq "$PATTERN"; then
        echo "[!] Possible database error indicator:"
        echo "    $PATTERN"
        ERRORS=$((ERRORS + 1))
    fi
}

check_error "SQL syntax"
check_error "mysql"
check_error "mysqli"
check_error "PostgreSQL"
check_error "pg_query"
check_error "SQLite"
check_error "ODBC"
check_error "Microsoft SQL Server"
check_error "ORA-[0-9]+"
check_error "Unclosed quotation mark"
check_error "You have an error in your SQL syntax"

echo

if [ "$ERRORS" -gt 0 ]; then
    echo "[!] Database-related error indicators detected."
    echo "[!] This is NOT proof of SQL injection."
    echo "[*] Verify manually on an authorized test target."
else
    echo "[+] No common database error indicators detected."
fi

echo
echo "[+] SQLi detection check completed."
