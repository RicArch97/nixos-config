# Configuration for EWW (Elkowar's Wacky Widgets)
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  ewwConfig = config.modules.desktop.util.eww;
  swayConfig = config.modules.desktop.sway;
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
    home.packages = lib.mkMerge [
      [
        pkgs.swaysome
        pkgs.bash
        pkgs.bluez
        pkgs.coreutils
        pkgs.xdg-utils
        pkgs.gawk
        pkgs.gnugrep
        pkgs.gnused
        pkgs.procps
        pkgs.findutils
        pkgs.jq
        pkgs.networkmanager
        pkgs.pulseaudio
        pkgs.wireplumber
      ]
      (lib.mkIf (!swayConfig.enable) [
        # This is installed systemwide when module is enabled
        pkgs.sway
      ])
    ];

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
