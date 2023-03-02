{
  description = "System configuration";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.11"; 
    home-manager.inputs.nixpkgs.follows = "stable";

    nix-matlab.url = "gitlab:doronbehar/nix-matlab";
    nix-matlab.inputs.nixpkgs.follows = "stable";
  };

  outputs = { stable, unstable, home-manager, nix-matlab, ... }@inputs:
  let
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  in {
    # normal stuff
    nixosConfigurations = {
      zephyrus = stable.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [ ./hosts/zephyrus/configuration.nix ];
      };
    };

    # home-manager stuff
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    homeConfigurations = {
      bennett = home-manager.lib.homeManagerConfiguration {
        pkgs = import stable {inherit system config;};
        extraSpecialArgs = inputs;
        modules = [ ./users/bennett/home.nix ];
      };
    };
  };
}
