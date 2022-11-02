# Configuration for the swayidle daemon
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  idleConfig = config.modules.desktop.services.swayidle;
  defaultApps = config.modules.desktop.defaultApplications.apps;
in {
  options.modules.desktop.services.swayidle = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (idleConfig.enable) {
    # Wayland output management
    home.packages = [pkgs.wlopm];

    # home manager configuration
    home.manager.services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${defaultApps.locker.cmd}";
        }
      ];
      timeouts = [
        {
          timeout = 600;
          command = "${defaultApps.locker.cmd}";
        }
        {
          timeout = 1800;
          command = "${pkgs.wlopm}/bin/wlopm --off \*";
          resumeCommand = "${pkgs.wlopm}/bin/wlopm --on \*";
        }
      ];
    };
  };
}
