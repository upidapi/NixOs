#!/bin/env bash

cd "$(dirname "$0")" || exit 1
nix shell nixpkgs#inotify-tools github:aylur/ags#agsFull -c bash "./_run_dbg.sh"

