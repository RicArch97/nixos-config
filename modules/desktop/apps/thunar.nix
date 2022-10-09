# Configuration for Thunar file manager
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  thunarConfig = config.modules.desktop.apps.thunar;
in {
  options.modules.desktop.apps.thunar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (thunarConfig.enable) {
    modules.desktop.defaultApplications.apps = {
      file-manager = rec {
        package = pkgs.xfce.thunar;
        install = false; # installed by system
        cmd = "${package}/bin/thunar";
        desktop = "thunar";
      };
      # works with the thunar archive plugin
      archive = rec {
        package = pkgs.mate.engrampa;
        cmd = "${package}/bin/engrampa";
        desktop = "engrampa";
      };
    };

    programs.thunar = {
      enable = true;
      plugins = [
        pkgs.xfce.thunar-archive-plugin
        pkgs.xfce.thunar-volman
        pkgs.xfce.thunar-media-tags-plugin
      ];
    };
  };
}
