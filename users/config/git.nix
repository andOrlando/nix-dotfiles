{
  programs.git = {
    enable = true;
    userName = "andOrlando";
    userEmail = "bennettgillig@gmail.com";
    extraConfig = {
      core.editor="hx";
      init.defaultBranch="main";
      safe.directory=["/etc/nixos"];
      url."https://".insteadOf="git://";
    };
  };
}
