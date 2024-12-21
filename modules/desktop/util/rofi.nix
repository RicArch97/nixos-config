# Configuration for Rofi menu
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  rofiConfig = config.modules.desktop.util.rofi;
in {
  options.modules.desktop.util.rofi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.rofi-wayland;
    };
    menu.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (rofiConfig.enable) (lib.mkMerge [
    (lib.mkIf (rofiConfig.menu.enable) {
      modules.desktop.defaultApplications.apps.menu = {
        package = rofiConfig.package;
        cmd = "${rofiConfig.package}/bin/rofi -show drun -config $XDG_CONFIG_HOME/rofi/menu.rasi";
        desktop = "rofi";
      };

      # dependency
      home.packages = [pkgs.jq];

      home.configFile."rofi/menu.rasi".source = "${config.nixosConfig.configDir}/rofi/menu.rasi";
    })

    {
      # home manager configuration
      home.manager.programs.rofi = {
        enable = true;
        package = rofiConfig.package;
      };
    }
  ]);
}
