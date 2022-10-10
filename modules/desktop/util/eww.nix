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

  config = let
    # used in scripts
    dependencies = [
      pkgs.bash
      pkgs.sway
      pkgs.coreutils
      pkgs.findutils
      pkgs.gawk
      pkgs.gnused
      pkgs.psmisc
      pkgs.procps
      pkgs.jq
      pkgs.networkmanager
      pkgs.bluez
      pkgs.wireplumber
      pkgs.pulseaudio
    ];
  in
    lib.mkIf (ewwConfig.enable) {
      home.packages = dependencies;

      # home manager configuration
      home.manager = {
        programs.eww = {
          enable = true;
          package = ewwConfig.package;
          configDir = "${config.nixosConfig.configDir}/eww";
        };
        # systemd user service for the daemon
        systemd.user.services.eww-daemon = {
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
