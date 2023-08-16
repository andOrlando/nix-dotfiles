{
  description = "System configuration";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.05"; 
    home-manager.inputs.nixpkgs.follows = "stable";

    nix-matlab.url = "gitlab:doronbehar/nix-matlab";
    nix-matlab.inputs.nixpkgs.follows = "stable";
  };

  outputs = { self, stable, unstable, home-manager, nix-matlab, ... }@inputs:
  let
    inherit (self) outputs;
    system = "x86_64-linux";
    config = { allowUnfree = true; };
    
    nixpkgs-overlays = ({ config, system, ...}: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        # modifications to pkgs
        (final: _prev: {
          # packages
          save-manager = final.callPackage ./programs/save-manager {};
          whitakers-words = final.callPackage ./programs/whitakers-words {};
          picom-ibhagwan = final.callPackage ./programs/picom-ibhagwan {};
          spotify-adblock = final.callPackage ./programs/spotify-adblock {};
          
          # scripts
          rebuild = final.callPackage ./programs/rebuild {};
          printcolors = final.callPackage ./programs/printcolors {};

          # unstable packages
          unstable = import inputs.unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        })    
        # other stuff
        nix-matlab.overlay
      ];
    });
  
  in {
  
    # normal stuff
    nixosConfigurations = {
      zephyrus = stable.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nixpkgs-overlays
          ./hosts/zephyrus/configuration.nix
        ];
      };
      box1 = stable.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nixpkgs-overlays
          ./hosts/box1/configuration.nix
        ];
      };
    };

    # home-manager stuff
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    homeConfigurations = {
      bennett = home-manager.lib.homeManagerConfiguration {
        pkgs = import stable { inherit system config; };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          nixpkgs-overlays
          ./users/bennett/home.nix
        ];
      };
    };
  };
}
