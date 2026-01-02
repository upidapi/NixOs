#!/usr/bin/env bash

# Usage 
# bash gen-psw.sh username password

createUser() {
  local psw

  psw=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)
  pswHash=$(nix run gitlab:SpoodyTheOne/declarative-jellyfin#genhash -- \
    -k "$psw" \
    -i 210000 \
    -l 128 \
    -u)

  cat << EOF
        $1:
            password: $psw
            passwordHash: $pswHash
EOF
}


for j in {1..8}; do
  createUser "guest-$j"
done

for i in 0 10 13 17; do
  for j in {1..4}; do
    createUser "guest-$i-$j"
  done
done


