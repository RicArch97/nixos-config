# Configuration for the Alacritty terminal
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  alaConfig = config.modules.desktop.apps.terminals.alacritty;
  colorScheme = config.modules.desktop.themes.colors;
  fontStyles = config.modules.desktop.themes.fonts.styles;
in {
  options.modules.desktop.apps.terminals.alacritty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (alaConfig.enable) {
    modules.desktop.defaultApplications.apps.terminal = rec {
      package = pkgs.alacritty;
      install = false; # installed by home manager
      cmd = "${package}/bin/alacritty";
      desktop = "alacritty";
    };

    # home manager configuration
    home.manager.programs.alacritty = {
      enable = true;
      settings = {
        # window settings
        window = {
          dimensions = {
            columns = 180;
            lines = 45;
          };
          padding = {
            x = 10;
            y = 10;
          };
          dynamic_padding = true;
          opacity = 0.85;
        };

        # max lines in buffer
        scrolling.history = 10000;

        # font config
        font = let
          mono = fontStyles.mono;
        in {
          normal = {
            family = mono.family;
            style = "Regular";
          };
          bold = {
            family = mono.family;
            style = "Bold";
          };
          italic = {
            family = mono.family;
            style = "Italic";
          };
          bold_italic = {
            family = mono.family;
            style = "Bold Italic";
          };
          size = mono.size;
        };

        # colorscheme
        colors = let
          cc = colorScheme.colors;
          ct = colorScheme.types;
        in {
          primary = {
            background = ct.background-darker;
            foreground = ct.foreground;
          };
          normal = {
            black = cc.color0;
            red = cc.color1;
            green = cc.color2;
            yellow = cc.color3;
            blue = cc.color4;
            magenta = cc.color5;
            cyan = cc.color6;
            white = cc.color7;
          };
          bright = {
            black = cc.color8;
            red = cc.color9;
            green = cc.color10;
            yellow = cc.color11;
            blue = cc.color12;
            magenta = cc.color13;
            cyan = cc.color14;
            white = cc.color15;
          };

          draw_bold_text_with_bright_colors = true;
        };

        # selection settings
        selection.save_to_clipboard = true;

        # cursor settings
        cursor = {
          style.shape = "Underline";
          unfocused_hollow = false;
        };

        # mouse settings
        mouse.bindings = [
          {
            mouse = "Middle";
            action = "PasteSelection";
          }
        ];

        # key bindings
        keyboard.bindings = [
          {
            key = "V";
            mods = "Control|Shift";
            action = "Paste";
          }
          {
            key = "C";
            mods = "Control|Shift";
            action = "Copy";
          }
        ];
      };
    };
  };
}
