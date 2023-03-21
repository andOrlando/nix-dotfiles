pkgs:

{
  enable = true;

  settings = {
    theme = "onedark";
    editor.mouse = false;
  };
  
  languages = [
    {
      name = "latex";
      config.texlab = {
        build.onSave = true;
        build.forwardSearchAfter = true;
        forwardSearch.executable = "zathura";
        forwardSearch.args = ["--synctex-forward" "%l:1:%f" "%p"];
        chktex.onEdit = true;
      };
    }
  ];

}
