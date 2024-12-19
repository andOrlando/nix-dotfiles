{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [ brightnessctl slurp wl-clipboard ];
  wayland.windowManager.sway = {
    enable = true;
    config = {

      modifier = "Mod4";
      menu = "rofi -show drun";
      terminal = "kitty";
      keybindings = let mod = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "Print" = "exec grim -g \"$(slurp -d)\" - | wl-copy";
        "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
        "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
        "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
        "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
      };
      window = {
        border = 3;
        titlebar = false;
      };
      fonts.size = 13.0;

      bars = [{
        position="top";
        statusCommand="${pkgs.i3status-rust.out}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
      }];

      
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

      	background-color = mkLiteral "white";
      	text-color = mkLiteral "black";
      };
      "#window" = {
        height = mkLiteral "100%";
        width = mkLiteral "30em";
        location = mkLiteral "west";
        anchor = mkLiteral "west";
        border = mkLiteral "4px";
      	# border-color = mkLiteral "@accent";
      };
      "#inputbar" = {
        padding = mkLiteral "8px";
        border = mkLiteral "0px 0px 4px 0px";
      	# border-color = mkLiteral "@accent";
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
      	text-color = mkLiteral "white";
      	background-color = mkLiteral "black";
      };
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars.top = {
      blocks = [
        { block = "music";
          player = "spotify";
        }
        { block = "sound"; }
        { block = "backlight";
          format = " $brightness ";
        }
        { block = "net";
          format = " $signal_strength $ssid ";
        }
        { block = "battery";
          device = "BAT0";
          format = " $percentage ";
          full_format = " $percentage ";
          charging_format = " $percentage chg ";
          not_charging_format = " $percentage ";
          empty_format = " $percentage ";
          missing_format = " missing ";
        }
        { block = "battery";
          device = "BAT1";
          format = " $percentage ext ";
          full_format = " $percentage ext ";
          charging_format = " $percentage ext chg ";
          not_charging_format = " $percentage ext ";
          empty_format = " $percentage ext ";
          missing_format = " missing ext ";
        }
        { block = "battery";
          device = "DisplayDevice";
          driver = "upower";
          format = " $percentage $power ";
          full_format = " $percentage $power ";
          charging_format = " $percentage $power $time ";
          not_charging_format = " $percentage $power ";
          empty_format = " $percentage $power ";
          missing_format = " missing ";
        }
        { block = "time";
          format = " $timestamp.datetime(f:'%a %d/%m %R') ";
        }
      ];
    };
  };
}
