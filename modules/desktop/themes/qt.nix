# Configuration for QT theming
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  qtConfig = config.modules.desktop.themes.qt;
in {
  options.modules.desktop.themes.qt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (qtConfig.enable) {
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
  };
}
