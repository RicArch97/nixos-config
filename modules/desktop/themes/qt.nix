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
    theme = {
      package = lib.mkOption {
        type = lib.types.package;
        default = null;
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "gtk2";
      };
    };
  };

  config = lib.mkIf (qtConfig.enable) {
    environment.variables = {
      QT_QPA_PLATFORMTHEME = "gtk2";
      QT_STYLE_OVERRIDE = qtConfig.theme.name;
    };

    # home manager configuration
    home.manager.qt = {
      enable = true;
      platformTheme = "gtk";
      style = {
        package = qtConfig.theme.package;
        name = qtConfig.theme.name;
      };
    };
  };
}
