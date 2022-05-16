{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  pythonDeps =
    (python3.withPackages (ps: with ps; with python3Packages; [
      jupyter
      ipython
    ]));
  cantor = pkgs.callPackage (import ./cantor.nix) {};
in

mkShell {
  buildInputs = [
    luajit
    cantor
    pythonDeps
    sage
    maxima
    octave
  ];
}
