# Configuration for Rofi menu
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  rofiConfig = config.modules.desktop.util.rofi;
  device = config.modules.device;
  swayConfig = config.modules.desktop.sway;
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
  };

  config = let
    launch-rofi-menu =
      if (rofiConfig.package != pkgs.rofi-wayland && swayConfig.enable && device.name == "X570AM")
      then
        # XWayland version doesn't detect focused output properly
        pkgs.writeShellScript "launch-rofi-menu-sway" ''
          output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused)' | jq -r '.name')

          if [[ $output == "${device.monitors.main.wayland_name}" ]]; then
            ${rofiConfig.package}/bin/rofi -show drun -config $XDG_CONFIG_HOME/rofi/menu.rasi -m 1
          elif [[ $output == "${device.monitors.side.wayland_name}" ]]; then
            ${rofiConfig.package}/bin/rofi -show drun -config $XDG_CONFIG_HOME/rofi/menu.rasi -m 0
          else
           echo "Error getting focused display"
          fi
        ''
      else "${rofiConfig.package}/bin/rofi -show drun -config $XDG_CONFIG_HOME/rofi/menu.rasi";
  in
    lib.mkIf (rofiConfig.enable) (lib.mkMerge [
      (lib.mkIf (rofiConfig.menu.enable) {
        modules.desktop.defaultApplications.apps.menu = {
          package = rofiConfig.package;
          cmd = launch-rofi-menu;
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
