# Configuration for the Xmonad window manager
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  xmonadConfig = config.modules.desktop.xmonad;
  device = config.modules.device;
  defaultApps = config.modules.desktop.defaultApplications.apps;
  colorScheme = config.modules.desktop.themes.colors;
  fontConfig = config.modules.desktop.themes.fonts.styles;
  gtkConfig = config.modules.desktop.themes.gtk;
in {
  # Options
  options.modules.desktop.xmonad = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  # Configuration
  config = lib.mkIf (xmonadConfig.enable) {
    # TODO
  };
}
