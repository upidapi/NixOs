#!/usr/bin/env bash

# Usage 
# bash gen-psw.sh username password

pswHash=$(nix run gitlab:SpoodyTheOne/declarative-jellyfin#genhash -- \
  -k "$2" \
  -i 210000 \
  -l 128 \
  -u)

cat << EOF
        $1:
            password: $2
            passwordHash: $pswHash
EOF
