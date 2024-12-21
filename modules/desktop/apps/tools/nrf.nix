# Configuration for NRF tools
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  nrfConfig = config.modules.desktop.apps.tools.nrf;
in {
  options.modules.desktop.apps.tools.nrf = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (nrfConfig.enable) {
    home.packages = [
      pkgs.master.nrf-command-line-tools
      pkgs.master.segger-jlink
      pkgs.master.nrfconnect
    ];

    # ensure we can connect to J-Link devices
    services.udev.packages = [
      pkgs.master.segger-jlink
      pkgs.master.nrf-udev
    ];
  };
}
