git clone https://github.com/upidapi/NixOs /tmp/nixos
nix-shell -p python --command "python /tmp/nixos/parts/install/install.py bootstrap"
