{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    userSettings = {
      "java.configuration.runtimes" = [
        {
          name = "JavaSE-17";
          path = "${pkgs.jdk17}/lib/openjdk";
          default = true;
        }
      ];
	  "java.jdt.ls.java.home" = "${pkgs.jdk17}/lib/openjdk";
    };
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      gruntfuggly.todo-tree
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "vscode-java-pack";
        publisher = "vscjava";
        version = "0.25.2022082700";
        sha256 = "sha256-Ntock5NjRojqAMlEJBBiPDovOGt5XEuuCugGlmuB4QY=";
      }
      {
        name = "vscode-eslint";
        publisher = "dbaeumer";
        version = "2.2.6";
        sha256 = "sha256-1yZeyLrXuubhKzobWcd00F/CdU824uJDTkB6qlHkJlQ=";
      }
    ];
  };
}
