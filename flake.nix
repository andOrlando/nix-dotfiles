{
  description = "System configurationa";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-26.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05"; 
    home-manager.inputs.nixpkgs.follows = "stable";

    nix-matlab.url = "gitlab:doronbehar/nix-matlab";
    nix-matlab.inputs.nixpkgs.follows = "stable";

    # aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    # aagl.inputs.nixpkgs.follows = "stable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    # nix-tmodloader.url = "github:andOrlando/nix-tmodloader";
    nix-tmodloader.url = "path:/home/ssh/nix-tmodloader";
    palworld-server-flake.url = "github:dp138504/palworld-server-flake";

    naviterm.url = "gitlab:detoxify92/naviterm";
    naviterm.inputs.nixpkgs.follows = "stable";

  };

  outputs = inputs@{
    self, stable, unstable, home-manager,
    nix-matlab,
    nix-minecraft,
    nix-tmodloader,
    palworld-server-flake,
    naviterm,
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

          # update palworld manifest
          palworld-server-unwrapped = _prev.palworld-server-unwrapped.overrideAttrs(old: {
            src = final.fetchSteam {
              name = "palworld-server";
              appId = "2394010";
              depotId = "2394012";
              manifestId = "1480973772525600530";
              hash = lib.fakeHash;
            };
          });
          steamworks-sdk-redist = _prev.steamworks-sdk-redist.overrideAttrs (old: {
            src = final.fetchSteam {
              name = "steamworks-sdk-redist";
              appId = "1007";
              depotId = "1006";
              manifestId = "5587033981095108078"; # unchanged, same manifest — just re-pin the hash
              hash = "sha256-qsmqBj3GlHZ47kyO0w3XlaTW2bC99nEjXrxEyGy5ico=";
            };
          });
        })
        # other stuff
        nix-matlab.overlay
        nix-minecraft.overlay
        nix-tmodloader.overlay
        (final: _prev: {
          naviterm = naviterm.packages.${final.system}.default;
        })
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
