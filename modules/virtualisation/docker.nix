# Configuration for docker
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  dockerConfig = config.modules.virtualisation.docker;
in {
  options.modules.virtualisation.docker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (dockerConfig.enable) {
    virtualisation.docker.enable = true;

    # permissions
    user.extraGroups = ["docker"];
  };
}
