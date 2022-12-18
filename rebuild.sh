function config() { sudo nixos-rebuild switch --flake path:$NIXOS_CONFIG_DIR#; }
function home() { nix run $NIXOS_CONFIG_DIR switch -- --flake $NIXOS_CONFIG_DIR; }

if [ "$1" = "home" ]; then home; fi
if [ "$1" = "config" ]; then config; fi
if [ "$1" = "" ]; then config; home; fi
