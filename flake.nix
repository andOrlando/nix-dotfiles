{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    qutebrowser-with-treetabs = {
      url = "github:mdarocha/nix-qutebrowser-with-treetabs";
    };
  };

  outputs = inputs@{ nixpkgs }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      overlays = [
        inputs.qutebrowser-with-treetabs.overlay
      ];
    in {
      nixosConfigurations.aNixosSystem = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          ({ nixpkgs, ... }: { nixpkgs.overlays = overlays; })
        ];
      };
    };
}
