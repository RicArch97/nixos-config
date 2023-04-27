# SwayNotificationCenter notification daemon configuration
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  swayncConfig = config.modules.desktop.services.swaync;
in {
  options.modules.desktop.services.swaync = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (swayncConfig.enable) {
    # hicolor is the fallback theme
    home.packages = [
      pkgs.swaynotificationcenter
      pkgs.libnotify
      pkgs.hicolor-icon-theme
    ];

    home.configFile = {
      "swaync/config.json" = {
        source = "${config.nixosConfig.configDir}/swaync/config.json";
      };
      "swaync/style.css" = {
        source = "${config.nixosConfig.configDir}/swaync/style.css";
      };
    };
  };
}
