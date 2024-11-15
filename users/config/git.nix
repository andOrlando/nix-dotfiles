{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "andOrlando";
    userEmail = "bennettgillig@gmail.com";
    package = pkgs.gitFull;
    extraConfig = {
      core.editor="hx";
      init.defaultBranch="main";
      safe.directory=["/etc/nixos"];
      url."https://".insteadOf="git://";
      config.credential.helper = "store";
    };
  };
  # programs.git-credential-oauth.enable = true;
}
