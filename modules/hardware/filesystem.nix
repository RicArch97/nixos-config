# Configuration for filesystem
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  fsConfig = config.modules.hardware.filesystem;
  device = config.modules.device;
in {
  options.modules.hardware.filesystem = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    zfs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      unstable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = let
    zfsMount = device: {
      inherit device;
      fsType = "zfs";
      options = ["zfsutil" "X-mount.mkdir"];
    };
  in
    lib.mkIf (fsConfig.enable) (lib.mkMerge [
      {
        # mount partitions (by default root is ext4, when zfs not enabled)
        # this is just according to the official install guide
        fileSystems = {
          "/" = {
            device = lib.mkDefault "/dev/disk/by-label/nixos";
            fsType = lib.mkDefault "ext4";
          };
          "/boot" = {
            device = "/dev/disk/by-label/boot";
            fsType = "vfat";
          };
        };
        swapDevices = [{device = "/dev/disk/by-label/swap";}];

        # save storage by hardlinking duplicate files to a single copy
        nix.settings.auto-optimise-store = lib.mkDefault true;

        # filesystem mounting
        services.gvfs.enable = true;

        # for NTFS expansion drives
        boot.supportedFilesystems = ["ntfs"];

        # permissions
        user.extraGroups = ["storage" "dialout"];
      }

      (lib.mkIf (device.drive == "nvme") {
        boot.initrd.kernelModules = ["nvme"];
      })

      (lib.mkIf (!fsConfig.zfs.enable && device.drive == "ssd") {
        services.fstrim.enable = true;
      })

      (lib.mkIf (fsConfig.zfs.enable) (lib.mkMerge [
        {
          # filsystem takes care of hardlinks
          nix.settings.auto-optimise-store = false;

          fileSystems = {
            "/" = zfsMount "rpool/root";
            "/var/lib" = zfsMount "rpool/var/lib";
            "/var/log" = zfsMount "rpool/var/log";
            "/var/cache" = zfsMount "rpool/var/cache";
            "/nix" = zfsMount "rpool/nix";
            "/home" = zfsMount "rpool/home";
          };

          boot = {
            supportedFilesystems = ["zfs"];
            kernelModules = ["zfs"];
            # kernels with ZFS support
            kernelPackages =
              if fsConfig.zfs.unstable
              then
                (pkgs.linuxPackages_latest.extend (_: prev: {
                  zfsUnstable = prev.zfsUnstable.overrideAttrs (self: {
                    meta = self.meta // {broken = false;};
                  });
                }))
              else config.boot.zfs.package.latestCompatibleLinuxPackages;
            zfs = {
              enableUnstable = fsConfig.zfs.unstable;
              forceImportAll = false;
              forceImportRoot = false;
            };
          };
          services.zfs.autoScrub = {
            enable = true;
            interval = "weekly";
          };
        }

        (lib.mkIf (device.drive == "ssd") {
          services.fstrim.enable = false;
          services.zfs.trim = {
            enable = true;
            interval = "weekly";
          };
        })
      ]))
    ]);
}
