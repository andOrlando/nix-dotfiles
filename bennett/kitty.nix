pkgs:

{
  enable = true;

  settings = {
    font_family = "Fantasque Sans Mono Regular Nerd Font Complete";
    bold_font = "Fantasque Sans Mono Bold Nerd Font Complete";
    italic_font = "Fantasque Sans Mono Italic Nerd Font Complete";
    bold_italic_font = "Fantasque Sans Mono Bold Italic Nerd Font Complete";

    font_size = 13;
    window_margin_width = 5;
    enable_audio_bell = "no";

    foreground = "#E9EBF3";
    background = "#71798f";
	background_opacity = "0.1";
    dynamic_background_opacity = "yes";
    color0 = "#13151C";
    color8 = "#3D4465";
    color1 = "#F46765";
    color9 = "#FF6292";
    color2 = "#8CCA24";
    color10 = "#A4FF36";
    color3 = "#FFDF3B";
    color11 = "#F8F583";
    color4 = "#7753DD";
    color12 = "#AC93F6";
    color5 = "#BA3FAC";
    color13 = "#E480D9";
    color6 = "#3D9BD7";
    color14 = "#7FC0E9";
    color7 = "#C3D1D6";
    color15 = "#E9EBF3";

    selection_background = "#3D4465";
    selection_foreground = "#E9EBF3";

    active_tab_font_style = "bold";
    inactive_tab_font_style = "normal";
    tab_bar_edge = "bottom";

    tab_bar_style = "separator";
    tab_separator = "\"\"";
	tab_title_template = "\"{fmt.fg._E9EBF3}{fmt.bg._71798f}  {title} \"";
	active_tab_title_template = "{fmt.fg._525867}{fmt.bg._71798f} {fmt.bg._525867}{fmt.fg._E9EBF3}{title}{fmt.fg._525867}{fmt.bg._71798f}";
    
    confirm_os_window_close = 0;
  };

}
