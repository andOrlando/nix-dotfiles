{ pkgs, ... }:
let
  git-libsecret = pkgs.gitFull.override { withLibsecret = true; };
in
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user.email = "andOrlando";
      user.name = "bennettgillig@gmail.com";
      core.editor="hx";
      init.defaultBranch="main";
      safe.directory=["/etc/nixos"];
      url."https://".insteadOf="git://";
      config.credential.helper = "store";
    };
    lfs.enable = true;
  };
  # programs.git-credential-oauth.enable = true;
}
