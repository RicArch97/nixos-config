# Configuration for networking
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  networkConfig = config.modules.hardware.network;
  device = config.modules.device;
in {
  options.modules.hardware.network = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (networkConfig.enable) {
    networking = {
      hostName = device.name;
      hostId = builtins.substring 0 8 (
        builtins.hashString "md5" config.networking.hostName
      );
      networkmanager.enable = true;
      firewall = {
        enable = true;
        # HTTP ports
        allowedTCPPorts = [80 443 8080];
        # random TCP port ranges for free use for own apps
        allowedTCPPortRanges = [
          {
            from = 14415;
            to = 14935;
          }
        ];
        # random UDP port ranges for free use for own apps
        allowedUDPPortRanges = [
          {
            from = 26490;
            to = 26999;
          }
        ];
      };
    };

    # permissions
    user.extraGroups = ["networkmanager"];
  };
}
