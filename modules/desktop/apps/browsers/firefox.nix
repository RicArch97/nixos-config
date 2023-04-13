# configuration for Firefox
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  firefoxConfig = config.modules.desktop.apps.browsers.firefox;
in {
  options.modules.desktop.apps.browsers.firefox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    setDefault = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (firefoxConfig.enable) (lib.mkMerge [
    {
      # allows opening links in FF
      env.MOZ_DBUS_REMOTE = "1";

      # xdg-open
      home.packages = [pkgs.xdg-utils];

      # home manager configuration
      home.manager.programs.firefox = {
        enable = true;
        package = pkgs.firefox;
        profiles.default = {
          settings = {
            "media.ffmpeg.vaapi.enabled" = true;
          };
        };
      };
    }

    (lib.mkIf (firefoxConfig.setDefault) {
      modules.desktop.defaultApplications.apps.browser = rec {
        package = pkgs.firefox;
        install = false; # installed by home manager
        cmd = "${package}/bin/firefox";
        desktop = "firefox";
      };
    })
  ]);
}
