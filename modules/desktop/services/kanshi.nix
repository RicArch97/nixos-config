# Kanshi automatic output configuration daemon
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  kanshiConfig = config.modules.desktop.services.kanshi;
  colorScheme = config.modules.desktop.themes.colors;
  device = config.modules.device;
in {
  options.modules.desktop.services.kanshi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (kanshiConfig.enable) {
    # home manager configuration
    home.manager.services.kanshi = {
      enable = true;
      profiles = {
        standalone = lib.mkIf (device.name == "T470") {
          outputs = [
            {criteria = "eDP-1";}
          ];
        };
        office = lib.mkIf (device.name == "T470") {
          outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
            }
            {
              criteria = "HDMI-A-2";
              mode = "1920x1080@60Hz";
              position = "1920,0";
            }
          ];
        };
      };
    };
  };
}
