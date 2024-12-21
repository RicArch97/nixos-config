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
    monitors = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          name = lib.mkOption {type = lib.types.str;};
          resolution = lib.mkOption {type = lib.types.str;};
          refresh_rate = lib.mkOption {type = lib.types.int;};
          position = {
            x = lib.mkOption {type = lib.types.int;};
            y = lib.mkOption {type = lib.types.int;};
          };
          primary = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          scale = lib.mkOption {
            type = lib.types.float;
            default = 0;
          };
          adaptive_sync = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          rotation = lib.mkOption {
            type = lib.types.enum ["0" "90" "180" "270"];
            default = "0";
          };
        };
      }));
      description = "monitor settings";
    };
  };
}
