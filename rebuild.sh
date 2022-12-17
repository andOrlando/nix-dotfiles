sudo nixos-rebuild switch --flake path:$NIXOS_CONFIG_DIR#
nix run . switch -- --flake $NIXOS_CONFIG_DIR
