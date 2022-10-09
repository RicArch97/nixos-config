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
      # GUI audio management
      home.packages = [pkgs.pavucontrol pkgs.pamixer];
    }

    (lib.mkIf (audioConfig.bluetooth.enable) {
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluezFull;
        powerOnBoot = false;
      };

      # enable SBC-XQ / mSBC in Wireplumber
      home.configFile = {
        "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
            bluez_monitor.properties = {
              ["bluez5.enable-sbc-xq"] = true,
              ["bluez5.enable-msbc"] = true,
              ["bluez5.enable-hw-volume"] = true,
              ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
          }
        '';
      };

      # permissions
      user.extraGroups = ["bluetooth"];
    })
  ]);
}
