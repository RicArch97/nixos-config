# Configuration for CPU
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  cpuConfig = config.modules.hardware.cpu;
  device = config.modules.device;
in {
  options.modules.hardware.cpu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cpuConfig.enable (lib.mkMerge [
    {
      # allow propriertary software
      hardware.enableRedistributableFirmware = true;

      environment.systemPackages = [config.boot.kernelPackages.cpupower];
    }

    (lib.mkIf device.cpu
      == "amd" {
        hardware.cpu.amd.updateMicrocode = true;
        # amd virtualization support
        boot.initrd.kernelModules = ["kvm_amd"];
      })

    (lib.mkIf device.cpu
      == "intel" {
        hardware.cpu.intel.updateMicrocode = true;
        # intel virtualization support
        boot.initrd.kernelModules = ["kvm_intel"];
      })
  ]);
}
