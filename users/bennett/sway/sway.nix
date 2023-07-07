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
  };
in
{
  home.packages = with pkgs; [ brightnessctl ];

  wayland.windowManager.sway = {
    enable = true;
    config = rec {

      modifier = "Mod4";
      menu = "rofi -show drun";

      terminal = "kitty";
      keybindings = lib.mkOptionDefault {
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
          background = mytheme.blue;
          border = mytheme.blue;
          childBorder = mytheme.blue;
          indicator = mytheme.cyan;
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
            background = mytheme.blue;
            border = mytheme.blue;
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
    };
  };
  
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = ./rofi-theme-sway.rasi;
  };

  programs.i3status-rust = {
    enable = true;
    bars.top = {
      blocks = [
        { block = "sound";
        }
        { block = "time";
          # format = "$timestamp.datetime(f:'%a %d/%m %R')";
        }
        { block = "battery";
          # format = "$percentage $time $power";
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
          separator = "";
          separator_bg = "auto";
          separator_fg = "auto";
        };
      };
    };
  };
}
