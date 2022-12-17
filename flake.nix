{
  description = "System configuration";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.11"; 
    home-manager.inputs.nixpkgs.follows = "stable";
  };

  outputs = { stable, unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      zephyrus = stable.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [ ./hosts/zephyrus/configuration.nix ];
      };
    };
    homeManagerConfigurations = {
      bennett = home-manager.lib.homeManagerConfiguration {
        inherit stable;
        specialArgs = inputs;
        modules = [ ./users/bennett/home.nix ];
      };
    };
  };
}
