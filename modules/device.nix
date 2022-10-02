# Defines device attributes for deciding whether to enable components
# inspired by balsoft
{
  config,
  options,
  lib,
  ...
}: {
  options.modules.device = {
    name = lib.mkOption {type = lib.types.str;};
    cpu = lib.mkOption {type = lib.types.enum ["amd" "intel"];};
    gpu = lib.mkOption {type = lib.types.enum ["amd" "intel" "nvidia"];};
    drive = lib.mkOption {type = lib.types.enum ["ssd" "nvme"];};
    hasTouchpad = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    hasFingerprint = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    supportsBrightness = lib.mkOption {type = lib.types.bool;};
    supportsBluetooth = lib.mkOption {type = lib.types.bool;};
    bigScreen = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    displayProtocol = lib.mkOption {type = lib.types.enum ["x11" "wayland"];};
  };
}
