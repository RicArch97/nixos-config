# Configuration for EWW (Elkowar's Wacky Widgets)
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  ewwConfig = config.modules.desktop.services.eww;
  swayConfig = config.modules.desktop.sway;
in {
  options.modules.desktop.services.eww = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.eww;
    };
  };

  config = let
    dependencies = [
      ewwConfig.package
      pkgs.sway
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
      pkgs.connman
      pkgs.pulseaudio
      pkgs.wireplumber
    ];
  in
    lib.mkIf (ewwConfig.enable) {
      # home manager configuration
      home.manager = {
        programs.eww = {
          enable = true;
          package = ewwConfig.package;
          configDir = "${config.nixosConfig.configDir}/eww";
        };

        systemd.user.services.eww = {
          Unit = {
            Description = "Eww Daemon";
            PartOf = ["graphical-session.target"];
          };
          Service = {
            Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
            ExecStart = "${ewwConfig.package}/bin/eww daemon --no-daemonize";
            Restart = "on-failure";
          };
          Install.WantedBy = ["graphical-session.target"];
        };
      };
    };
}
