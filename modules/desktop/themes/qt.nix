# Configuration for QT theming
{
  config,
  options,
  lib,
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
        name = "gtk2";
      };
    };
  };

  config = lib.mkIf qtConfig.enable {
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
