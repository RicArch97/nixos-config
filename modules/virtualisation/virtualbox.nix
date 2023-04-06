# Configuration for virtualbox
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  vboxConfig = config.modules.virtualisation.vbox;
in {
  options.modules.virtualisation.vbox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.virtualbox;
    };
  };

  config = lib.mkIf (vboxConfig.enable) {
    virtualisation.virtualbox.host = {
      enable = true;
      package = vboxConfig.package;
      headless = true;
    };

    # permissions
    user.extraGroups = ["vboxusers"];
  };
}
