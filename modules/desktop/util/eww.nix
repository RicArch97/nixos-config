# Configuration for EWW (Elkowar's Wacky Widgets)
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  ewwConfig = config.modules.desktop.util.eww;
  colorScheme = config.modules.desktop.themes.colors;
  fontConfig = config.modules.desktop.themes.fonts.styles;
in {
  options.modules.desktop.util.eww = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.eww;
    };
  };

  config = lib.mkIf (ewwConfig.enable) {
      # home manager configuration
      home.manager = {
        programs.eww = {
          enable = true;
          package = ewwConfig.package;
          configDir = "${config.nixosConfig.configDir}/eww";
        };
      };
    };
}
