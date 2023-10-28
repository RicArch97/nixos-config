/*
X570AM - Full AMD entertainment / gaming system.

Gigabyte X570 Aorus Master motherboard
AMD Ryzen 9 5950X processor
AMD Radeon RX 6900XT graphics card
32 GB RAM
Multiple NVMe drives and one SSD

Should contain gaming related apps and services like Steam, Lutris, Wine.
Created with multi monitor setup in mind.
*/
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Allow SMBus access for OpenRGB device interaction
    kernelParams = ["acpi_enforce_resources=lax"];
    kernelModules = ["i2c-dev" "i2c-piix4"];
  };

  # Enable OpenRGB udev rules
  services.udev.packages = [pkgs.openrgb];

  # Mount additional drives
  fileSystems = {
    "/media/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "ext4";
      options = ["defaults"];
    };
  };

  # Host specific user packages
  home.packages = [
    # multimedia
    pkgs.gimp
    pkgs.drawing
    # utils
    pkgs.neofetch
    pkgs.openrgb
  ];

  modules = {
    device = {
      cpu = "amd";
      gpu = "amd";
      drive = "nvme"; # where the os is installed
      supportsBrightness = false;
      supportsBluetooth = true;
      monitors = {
        main = {
          x11_name = "DisplayPort-0";
          wayland_name = "DP-1";
          resolution = "3440x1440";
          modeline = "889.09 3440 3584 3616 3680 1440 1443 1453 1510 +hsync -vsync";
          position = {
            x = 2560;
            y = 0;
          };
          refresh_rate = 160;
          adaptive_sync = true;
          primary = true;
        };
        side = {
          x11_name = "DisplayPort-1";
          wayland_name = "DP-2";
          resolution = "2650x1440";
          position = {
            x = 0;
            y = 0;
          };
          refresh_rate = 165;
          adaptive_sync = true;
        };
      };
    };
    shell = {
      git.enable = true;
      gpg.enable = true;
      passwords.enable = true;
    };
    hardware.network = {
      networkmanager.enable = false;
      connman.enable = true;
    };
    desktop = {
      awesome.enable = true;
      gaming.enable = true;
      util.mpv.enable = true;
      apps = {
        browsers = {
          firefox.enable = true;
          chrome = {
            enable = true;
            setDefault = false;
          };
        };
        discord.enable = true;
        thunar.enable = true;
        vscode.enable = true;
        zathura.enable = true;
      };
    };
  };
}
