#!/bin/bash
DIR=$(nix eval -f $HOME/.config/nixos/local.nix configdir | tr -d '"')

function config() { sudo nixos-rebuild switch --flake path:$DIR#; }
function home() { nix run $DIR switch -- --flake $DIR; }
function update() { nix flake update path:$DIR; }

# function config() { sudo nixos-rebuild switch --flake path:/home/bennett/.config/nixos#; }
# function home() { nix run /home/bennett/.config/nixos switch -- --flake /home/bennett/.config/nixos; }
# function update() { nix flake update path:/home/bennett/.config/nixos; }

if [ "$1" = "home" ]; then home; fi
if [ "$1" = "config" ]; then config; fi
if [ "$1" = "update" ]; then update; fi
if [ "$1" = "" ]; then config; home; fi