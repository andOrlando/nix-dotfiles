function config() { sudo nixos-rebuild switch --flake path:/home/bennett/.config/nixos#; }
function home() { nix run /home/bennett/.config/nixos switch -- --flake /home/bennett/.config/nixos; }

if [ "$1" = "home" ]; then home; fi
if [ "$1" = "config" ]; then config; fi
if [ "$1" = "" ]; then config; home; fi
