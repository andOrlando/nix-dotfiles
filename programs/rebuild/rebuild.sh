function config() { sudo nixos-rebuild switch --flake path:/etc/nixos#; }
function update() { nix flake update --flake path:/etc/nixos; }

if [ "$1" = "config" ]; then config; fi
if [ "$1" = "update" ]; then update; fi
if [ "$1" = "" ]; then config; fi
