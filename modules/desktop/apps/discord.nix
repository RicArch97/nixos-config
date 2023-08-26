# Configuration for Discord
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  discordConfig = config.modules.desktop.apps.discord;
in {
  options.modules.desktop.apps.discord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (discordConfig.enable) {
    home.manager.programs.discocss = {
      enable = true;
      package = pkgs.discocss;
      discordPackage = pkgs.discord;
      discordAlias = true;
      css = builtins.readFile "${config.nixosConfig.configDir}/discord/GitHub-Dark.theme.css";
    };
  };
}
