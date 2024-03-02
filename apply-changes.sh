# exit immediately if a command exits with a non-zero status
set -e
pushd /etc/nixos/

# formatt code, ignore output
echo "Formatting Files..."
alejandra . #  &>/dev/null

# show git diff
git diff -U0 *.nix

# rebuild ignore everything except errors
echo "NixOS Rebuilding (profile: $0)..."
nixos-rebuild switch --flake /etc/nixos#$0 

# &>nixos-switch.log || (
#  cat nixos-switch.log | grep --color error && false)

gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen $1"

popd

