# Global font configuration
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  fontConf = config.modules.desktop.themes.fonts;
  font = defaultFamily: defaultSize: {
    family = lib.mkOption {
      type = lib.types.str;
      default = defaultFamily;
    };
    size = lib.mkOption {
      type = lib.types.int;
      default = defaultSize;
    };
  };
in {
  options.modules.desktop.themes.fonts = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    styles = {
      main = font "Product Sans" 11;
      sub = font "Inter" 11;
      serif = font "IBM Plex Serif" 11;
      mono = font "JuliaMono" 12;
      icons = font "Material Design Icons" 12;
      emoji = font "Noto Color Emoji" 12;
    };
  };

  config = lib.mkIf (fontConf.enable) {
    fonts = {
      fonts = [
        pkgs.custom.product-sans
        pkgs.custom.phosphor
        pkgs.inter
        pkgs.nerdfonts
        pkgs.julia-mono
        pkgs.ibm-plex
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk
        pkgs.noto-fonts-emoji
        pkgs.material-design-icons
        pkgs.material-icons
        pkgs.font-awesome
      ];
      fontconfig = let
        styles = fontConf.styles;
      in {
        enable = true;
        antialias = true;
        hinting = {
          enable = true;
          style = "hintslight";
          autohint = false;
        };
        defaultFonts = {
          sansSerif = ["${styles.main.family} ${toString styles.main.size}"];
          serif = ["${styles.serif.family} ${toString styles.serif.size}"];
          monospace = ["${styles.mono.family} ${toString styles.mono.size}"];
          emoji = ["${styles.emoji.family} ${toString styles.emoji.size}"];
        };
      };
      enableDefaultFonts = true;
    };
  };
}
