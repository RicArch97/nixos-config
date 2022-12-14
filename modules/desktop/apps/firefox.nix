# configuration for Firefox
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  firefoxConfig = config.modules.desktop.apps.firefox;
in {
  options.modules.desktop.apps.firefox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firefox;
    };
  };

  config = lib.mkIf (firefoxConfig.enable) {
    modules.desktop.defaultApplications.apps.browser = rec {
      package = firefoxConfig.package;
      install = false; # installed by home manager
      cmd = "${package}/bin/firefox";
      desktop = "firefox";
    };

    # allows opening links in FF
    env.MOZ_DBUS_REMOTE = "1";

    # xdg-open
    home.packages = [pkgs.xdg-utils];

    # home manager configuration
    home.manager.programs.firefox = {
      enable = true;
      package = firefoxConfig.package;
      profiles.default = {
        settings = {
          "media.ffmpeg.vaapi.enabled" = true;
        };
      };
    };
  };
}
