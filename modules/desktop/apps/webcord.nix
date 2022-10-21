# Configuration for Webcord
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  webcordConfig = config.modules.desktop.apps.webcord;
in {
  options.modules.desktop.apps.webcord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    themes = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {
        Github-Dark = "${config.nixosConfig.configDir}/discord/GitHub-Dark.theme.css";
      };
    };
  };

  config = lib.mkIf (webcordConfig.enable) {
    home.packages = [pkgs.webcord];

    # for every theme provided, create a symlink in the conf dir
    # to the path provided
    home.configFile =
      lib.mapAttrs' (name: source: {
        name = "WebCord/Themes/${name}";
        value = {inherit source;};
      })
      webcordConfig.themes;
  };
}
