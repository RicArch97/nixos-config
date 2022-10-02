# Configuration for the swayidle daemon
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  idleConfig = config.modules.desktop.services.swayidle;
  apps = config.modules.desktop.default-apps.defaultApps;
in {
  options.modules.desktop.services.swayidle = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf idleConfig.enable {
    # use own wlopm package
    user.packages = [pkgs.wlopm];

    # home manager configuration
    home.manager.services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${apps.locker.cmd}";
        }
      ];
      timeouts = [
        {
          timeout = 600;
          command = "${apps.locker.cmd}";
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
