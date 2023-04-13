# configuration for Google chrome
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  chromeConfig = config.modules.desktop.apps.browsers.chrome;
in {
  options.modules.desktop.apps.browsers.chrome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    setDefault = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (chromeConfig.enable) (lib.mkMerge [
    {
      home.packages = [
        pkgs.google-chrome
        # xdg-open
        pkgs.xdg-utils
      ];
    }

    (lib.mkIf (chromeConfig.setDefault) {
      modules.desktop.defaultApplications.apps.browser = rec {
        package = pkgs.google-chrome;
        install = false; # installed above
        cmd = "${package}/bin/google-chrome-stable";
        desktop = "google-chrome";
      };
    })
  ]);
}
