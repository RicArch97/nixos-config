# Configuration for polkit
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  polkitConfig = config.modules.desktop.services.polkit;
in {
  options.modules.desktop.services.polkit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf polkitConfig.enable {
    # make sure polkit daemon is available
    security.polkit.enable = true;
    # for authentication dialogs
    environment.systemPackages = [pkgs.polkit_gnome];

    home.manager.systemd.user.services.polkit-agent = {
      Unit = {
        Description = "Run polkit authentication agent";
        X-RestartIfChanged = true;
      };
      Service.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
