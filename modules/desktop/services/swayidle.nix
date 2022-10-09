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
    # use own wlopm package
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
          timeout = 3600;
          command = "wlopm --off \*";
          resumeCommand = "wlopm --on \*";
        }
      ];
    };
  };
}
