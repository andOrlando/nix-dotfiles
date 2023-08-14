function config() { sudo nixos-rebuild switch --flake path:/etc/nixos#; }
function home() { nix run /etc/nixos switch -- --flake /etc/nixos; }
function update() { nix flake update path:/etc/nixos; }

if [ "$1" = "home" ]; then home; fi
if [ "$1" = "config" ]; then config; fi
if [ "$1" = "update" ]; then update; fi
if [ "$1" = "" ]; then config; home; fi
