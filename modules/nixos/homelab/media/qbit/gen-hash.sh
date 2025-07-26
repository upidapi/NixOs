#!/usr/bin/env nix-shell
#!nix-shell -i real-interpreter -p openssl -p xxd
#shellcheck shell=bash

set -euo pipefail

SALT_BYTES=16
KEY_LEN_BYTES=64
ITERATIONS=100000
DIGEST_ALGO="SHA512"

get_hashed_password() {
    PASSWORD="$1"

    SALT_HEX=$(
        openssl rand "$SALT_BYTES" |
            xxd -p -c 256 |
            tr -d '\n'
    )

    SALT_B64=$(
        echo -n "$SALT_HEX" |
            xxd -r -p |
            base64 |
            tr -d '\n='
    )

    DERIVED_KEY_B64=$(openssl kdf \
        -keylen "$KEY_LEN_BYTES" \
        -kdfopt digest:"$DIGEST_ALGO" \
        -kdfopt pass:"$PASSWORD" \
        -kdfopt hexsalt:"$SALT_HEX" \
        -kdfopt iter:"$ITERATIONS" \
        -binary \
        PBKDF2 |
        base64 |
        tr -d '\n=')

    echo "${SALT_B64}==:${DERIVED_KEY_B64}=="
}

get_hashed_password "your secret password"
