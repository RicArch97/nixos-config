# Configuration for gaming (Steam, Lutris)
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  gameConfig = config.modules.desktop.gaming;
  device = config.modules.device;
in {
  options.modules.desktop.gaming = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (gameConfig.enable) {
    # Steam hardware (just in case)
    hardware.steam-hardware.enable = true;

    # Steam and gamemode (optimization)
    programs = {
      steam.enable = true;
      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 10;
          };
          custom = {
            start = "${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations activated'";
            end = "${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations deactivated'";
          };
        };
      };
    };

    # Lutris, Wine and OBS studio for game capture
    home.packages = let
      winepkg =
        if device.displayProtocol == "wayland"
        then pkgs.wine-wayland
        else pkgs.wine;
    in
      [
        winepkg
        pkgs.lutris
        pkgs.gamescope
        pkgs.obs-studio
        pkgs.obs-studio-plugins.obs-gstreamer
        pkgs.obs-studio-plugins.obs-pipewire-audio-capture
        pkgs.obs-studio-plugins.obs-vkcapture
      ]
      ++ lib.optional (device.displayProtocol == "wayland")
      pkgs.obs-studio-plugins.wlrobs;

    # extra file descriptors for esync
    systemd.extraConfig = "DefaultLimitNOFILE=1048576";

    # i915 performance mode
    boot.kernel.sysctl = lib.mkIf (device.cpu == "intel") {"dev.i915.perf_stream_paranoid" = 0;};
  };
}
