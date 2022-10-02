# Configuration for storage
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  storageConfig = config.modules.hardware.storage;
  device = config.modules.device;
in {
  options.modules.hardware.storage = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    zfs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf storageConfig.enable (lib.mkMerge [
    {
      # drive automounting
      programs.udevil.enable = true;

      environment.systemPackages = [pkgs.sshfs pkgs.exfat pkgs.ntfs3g];

      # permissions
      user.extraGroups = ["storage"];
    }

    (lib.mkIf device.drive
      == "nvme" {
        boot.initrd.availableKernelModules = ["nvme"];
      })

    (lib.mkIf (!storageConfig.zfs.enable && device.drive == "ssd") {
      services.fstrim.enable = true;
    })

    (lib.mkIf storageConfig.zfs.enable (lib.mkMerge [
      {
        boot = {
          supportedFilesystems = ["zfs"];
          initrd.kernelModules = ["zfs"];
          # latest kernel with ZFS support
          kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
          # prevents ZFS issues according to https://nixos.wiki/wiki/ZFS
          kernelParams = ["nohibernate"];
        };
        services.zfs.autoScrub = {
          enable = true;
          pools = ["ospool"];
          interval = "weekly";
        };
      }

      (lib.mkIf device.drive
        == "ssd" {
          services.fstrim.enable = false;
          services.zfs.trim = {
            enable = true;
            interval = "weekly";
          };
        })
    ]))
  ]);
}
