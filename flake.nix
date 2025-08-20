{
  description = "System configurationa";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05"; 
    home-manager.inputs.nixpkgs.follows = "stable";

    nix-matlab.url = "gitlab:doronbehar/nix-matlab";
    nix-matlab.inputs.nixpkgs.follows = "stable";

    # aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    # aagl.inputs.nixpkgs.follows = "stable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-tmodloader.url = "github:andOrlando/nix-tmodloader";
    # nix-tmodloader.url = "path:/home/beni/projects/nix-tmodloader";
  };

  outputs = inputs@{
    self, stable, unstable, home-manager,
    nix-matlab,
    nix-minecraft,
    nix-tmodloader,
    ... }:
  let
    system = "x86_64-linux";
    
    nixpkgs-overlays = ({ config, system, ...}: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        # modifications to pkgs
        (final: _prev: {
          # packages
          save-manager = final.callPackage ./programs/save-manager.nix {};
          whitakers-words = final.callPackage ./programs/whitakers-words.nix {};
          picom-ibhagwan = final.callPackage ./programs/picom-ibhagwan.nix {};
          spotify-adblock = final.callPackage ./programs/spotify-adblock.nix {};
          awakened-poe-trade = final.callPackage ./programs/awakened-poe-trade.nix {};
          insomnium = final.callPackage ./programs/insomnium.nix {};
          
          # scripts
          rebuild = final.callPackage ./programs/rebuild {};
          printcolors = final.callPackage ./programs/printcolors {};
          startgnome = final.callPackage ./programs/startgnome {};

          # unstable packages
          unstable = import inputs.unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        })    
        # other stuff
        nix-matlab.overlay
        nix-minecraft.overlay
        nix-tmodloader.overlay
      ];
    });

    lib = stable.lib.extend(final: prev: prev // { helpers = import ./helpers.nix prev; });

    mkUsers = users: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users = builtins.listToAttrs (
        map (user: {name=user; value=./users/${user}/home.nix; })
        users
      );
    };
    mkSystem = name: users: stable.lib.nixosSystem {
      inherit system;
      specialArgs = inputs // { inherit lib; };
      modules = [
          nixpkgs-overlays
          ./homelab
          ./hosts/${name}/configuration.nix

          home-manager.nixosModules.home-manager
          (mkUsers users)

      ];
    };
  
  in {
  
    nixosConfigurations = {
      zephyrus = mkSystem "zephyrus" ["bennett"];
      t480 = mkSystem "t480" ["beni"];
      box1 = mkSystem "box1" ["ssh"];
    };
  };
}
