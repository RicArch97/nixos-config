# Configuration for MPV video player
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  mpvConfig = config.modules.desktop.util.mpv;
  device = config.modules.device;
in {
  options.modules.desktop.util.mpv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (mpvConfig.enable) {
    modules.desktop.defaultApplications.apps.video = rec {
      package = pkgs.mpv;
      install = false; # installed by home manager
      cmd = "${package}/bin/mpv";
      desktop = "mpv";
    };

    # home manager configuration
    home.manager.programs.mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        gpu-api = "vulkan";
        gpu-context =
          if device.displayProtocol == "wayland"
          then "waylandvk"
          else "x11vk";
        vo = "gpu";
        hwdec = "auto";
        keep-open = "yes";
      };
    };
  };
}
