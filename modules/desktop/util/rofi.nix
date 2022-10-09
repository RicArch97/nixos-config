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
      default = pkgs.rofi;
    };
    menu.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    exit.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (rofiConfig.enable) (lib.mkMerge [
    (lib.mkIf (rofiConfig.menu.enable) {
      modules.desktop.defaultApplications.apps.menu = rec {
        package = rofiConfig.package;
        cmd = "${package}/bin/rofi";
        desktop = "rofi"; #TODO config
      };
    })

    (lib.mkIf (rofiConfig.exit.enable) {
      modules.desktop.defaultApplications.apps.exit = rec {
        package = rofiConfig.package;
        cmd = "${package}/bin/rofi";
        desktop = "rofi"; #TODO config
      };
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
