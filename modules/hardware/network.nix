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
    networkmanager.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    connman.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (networkConfig.enable) (lib.mkMerge [
    {
      networking = {
        hostName = device.name;
        hostId = builtins.substring 0 8 (
          builtins.hashString "md5" config.networking.hostName
        );
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
    }

    (lib.mkIf (networkConfig.networkmanager.enable) {
      networking.networkmanager.enable = true;

      # permissions
      user.extraGroups = ["networkmanager"];
    })

    (lib.mkIf (networkConfig.connman.enable) {
      services.connman = {
        enable = true;
        package = pkgs.connmanFull;
        wifi.backend = "iwd";
        # Blacklist docker, and avoid race condition with eth# and wifi#, see Arch wiki
        networkInterfaceBlacklist = ["vmnet" "vboxnet" "virbr" "ifb" "ve" "docker" "veth" "eth" "wlan"];
        # prefer Ethernet over Wi-Fi
        extraConfig = ''
          [General]
          PreferredTechnologies=ethernet,wifi
        '';
      };

      # Front-end for connman
      home.packages = [pkgs.cmst];
    })
  ]);
}
