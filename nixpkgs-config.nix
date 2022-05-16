{ pkgs, ... }:
let
  unstableNixosTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  nurTarball = fetchTarball https://github.com/nix-community/NUR/archive/master.tar.gz;
in
{
  packageOverrides = pkgs: {
    unstable = import unstableNixosTarball { config = { allowUnfree = true; }; };
    nur = import nurTarball { inherit pkgs; };
  };

  allowUnfree = true;
}
