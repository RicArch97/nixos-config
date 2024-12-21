# Configuration for audio
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  audioConfig = config.modules.hardware.audio;
  device = config.modules.device;
in {
  options.modules.hardware.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    bluetooth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = device.supportsBluetooth;
      };
    };
  };

  config = lib.mkIf (audioConfig.enable) (lib.mkMerge [
    {
      hardware.pulseaudio.enable = false;

      # able to change scheduling policies, e.g. to SCHED_RR
      security.rtkit.enable = true;

      # enable PipeWire
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # permissions
      user.extraGroups = ["audio"];
      # audio management
      home.packages = [pkgs.pavucontrol];
    }

    (lib.mkIf (audioConfig.bluetooth.enable) {
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluez;
        powerOnBoot = true;
        input = {
          General = {
            UserspaceHID = true;
          };
        };
      };

      services.blueman.enable = true;

      # permissions
      user.extraGroups = ["bluetooth"];
    })
  ]);
}
