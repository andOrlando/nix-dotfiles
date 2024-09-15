{ pkgs, lib, ... }:
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
    "plantuml.render" = "Local";
    "plantuml.java" = "${pkgs.jdk17}/bin/java";
    "plantuml.jar" = "${pkgs.plantuml}/lib/plantuml.jar";
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
      {
        name = "PlantUML";
        publisher = "jebbs";
        version = "2.17.5";
        sha256 = "sha256-C/kf+rYGTIdExxivNKHWeOzNsPAOWz2jn4sc52+sClA=";
      }
      {
        name = "codetogether";
        publisher = "genuitecllc";
        version = "2024.1.0";
        sha256 = "sha256-2rdalYoWrSytwCAkyam+CQJ++aDPmTQpEHkKXVlpl80=";
      }
    ];
  };
}
