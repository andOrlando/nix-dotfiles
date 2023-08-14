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

  outputs = { self, stable, unstable, home-manager, nix-matlab, ... }@inputs:
  let
    inherit (self) outputs;
    system = "x86_64-linux";
    config = { allowUnfree = true; };
    
    nixpkgs-overlays = ({ config, system, ...}: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        # additions
        (final: _prev: {
          save-manager = final.callPackage ./programs/save-manager {};
          whitakers-words = final.callPackage ./programs/whitakers-words {};
          picom-ibhagwan = final.callPackage ./programs/picom-ibhagwan {};
          spotify = final.callPackage ./programs/spotify {};
          
          rebuild = final.callPackage ./scripts/rebuild {};
        })    
        # unstable
        (final: _prev: {
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
      # box1 = stable.lib.nixosSystem {
        # inherit system;
        # specialArgs = inputs;
        # modules = [ ./hosts/box1/configuration.nix ];
      # };
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
