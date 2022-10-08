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
    };

    # Don't wait for network startup (speeds up boot time)
    systemd = {
      targets.network-online.wantedBy = lib.mkForce []; # Normally ["multi-user.target"]
      services.NetworkManager-wait-online.wantedBy = lib.mkForce []; # Normally ["network-online.target"]
    };

    # permissions
    user.extraGroups = ["networkmanager"];
  };
}
