{ config, lib, pkgs, ... }:
let
  mytheme = {
    bg = "#282c34";
    fg = "#abb2bf";
    blue = "#61afef";
    green = "#98c379";
    cyan = "#56b6c2";
    red = "#e06c75";
    orange = "#e5c07b";
    violet = "#c678dd";
    accent = mytheme.blue;
    accent2 = mytheme.cyan;
  };
in
{
  home.packages = with pkgs; [ brightnessctl slurp wl-clipboard ];

  wayland.windowManager.sway = {
    enable = true;
    config = rec {

      modifier = "Mod4";
      menu = "rofi -show drun";

      terminal = "kitty";
      keybindings = let mod = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "${mod}+p" = "exec grim -g \"$(slurp -d)\" - | wl-copy";
        "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
        "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
        "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
        "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";

      };
      window = {
        border = 4;
        titlebar = true;
      };
      fonts.size = 13.0;
      colors = {
        background = mytheme.bg;
        focused = {
          background = mytheme.accent;
          border = mytheme.accent;
          childBorder = mytheme.accent;
          indicator = mytheme.accent2;
          text = mytheme.bg;
        };
        focusedInactive = {
          background = mytheme.bg;
          border = mytheme.bg;
          childBorder = mytheme.bg;
          indicator = mytheme.bg;
          text = mytheme.fg;
        };
        placeholder = {
          background = mytheme.bg;
          border = mytheme.bg;
          childBorder = mytheme.bg;
          indicator = mytheme.bg;
          text = mytheme.fg;
        };
        unfocused = {
          background = mytheme.bg;
          border = mytheme.bg;
          childBorder = mytheme.bg;
          indicator = mytheme.bg;
          text = mytheme.fg;
        };
        urgent = {
          background = mytheme.orange;
          border = mytheme.orange;
          childBorder = mytheme.orange;
          indicator = mytheme.bg;
          text = mytheme.bg;
        };
      };
      
      bars = [{
        position="top";
        statusCommand="${pkgs.i3status-rust.out}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
        fonts.size = 13.0;
        trayOutput = "none";
        colors = {
          background = mytheme.bg;
          focusedWorkspace = {
            background = mytheme.accent;
            border = mytheme.accent;
            text = mytheme.bg;
          };
          activeWorkspace = {
            background = mytheme.violet;
            border = mytheme.violet;
            text = mytheme.bg;
          };
          inactiveWorkspace = {
            background = mytheme.bg;
            border = mytheme.bg;
            text = mytheme.fg;
          };
        };
      }];
      output.eDP-1 = {
        scale = "1.5";
        # bg = ???
      };
      output.eDP-2 = {
        scale = "1.5";
      };
      input."type:touchpad" = {
        tap = "enabled";
      };
    };
  };
  
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {
      	bg = mkLiteral mytheme.bg;
      	fg = mkLiteral mytheme.fg;
        accent = mkLiteral mytheme.blue;

      	background-color = mkLiteral "@bg";
      	text-color = mkLiteral "@fg";
      };
      "#window" = {
        height = mkLiteral "100%";
        width = mkLiteral "30em";
        location = mkLiteral "west";
        anchor = mkLiteral "west";
        border = mkLiteral "4px";
      	border-color = mkLiteral "@accent";
      };
      "#inputbar" = {
        padding = mkLiteral "8px";
        border = mkLiteral "0px 0px 4px 0px";
      	border-color = mkLiteral "@accent";
      };
      "#prompt" = {
      	text-transform = mkLiteral "bold";
      };
      "#entry" = {
      	padding = mkLiteral "0px 0px 0px 8px";
      	placeholder = "say something :/";
      };
      "#inputbar entry" = {
      	padding-left = mkLiteral "4px";
      };
      "#element-text" = {
      	padding = mkLiteral "0px 8px 0px 8px";
      	highlight = mkLiteral "bold";
      };
      "#element-text selected" = {
      	text-color = mkLiteral "@bg";
      	background-color = mkLiteral "@accent";
      };
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars.top = {
      blocks = [
        { block = "music";
          # format = " $artist - $title ";
          player = "spotify";
        }
        { block = "sound";
        }
        { block = "time";
          format = " $timestamp.datetime(f:'%a %d/%m %R') ";
        }
        { block = "battery";
          format = " $percentage $time $power ";
          full_format = " $percentage $time $power ";
        }
      ];
      settings = {
        theme.overrides = {
          idle_fg = mytheme.fg;
          idle_bg = mytheme.bg;
          info_fg = mytheme.fg;
          info_bg = mytheme.bg;
          good_fg = mytheme.green;
          good_bg = mytheme.bg;
          warning_fg = mytheme.orange;
          warning_bg = mytheme.bg;
          critical_fg = mytheme.fg;
          critical_bg = mytheme.red;
          separator = ".";
          separator_bg = "auto";
          separator_fg = mytheme.accent;
        };
      };
    };
  };
}
