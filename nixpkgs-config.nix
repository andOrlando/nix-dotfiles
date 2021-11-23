{ pkgs, ... }:
let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  packageOverrides = pkgs: {
    unstable = import unstableTarball {
      config = { allowUnfree = true; };
    };
  };

  allowUnfree = true;
}
