/*
X570AM - Full AMD work and gaming system.

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
  # Allow SMBus access for OpenRGB device interaction
  boot = {
    kernelParams = ["acpi_enforce_resources=lax"];
    kernelModules = ["i2c-dev" "i2c-piix4"];
  };

  # Enable OpenRGB udev rules
  services.udev.packages = [pkgs.openrgb];

  # Mount Data drive
  fileSystems."/media/data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "ntfs";
    options = ["rw" "uid=1000"];
  };

  # Host specific user packages
  home.packages = [
    # multimedia
    pkgs.google-chrome
    pkgs.discord
    pkgs.spotify
    pkgs.gimp
    pkgs.gimpPlugins.resynthesizer
    pkgs.drawing
    # utils
    pkgs.neofetch
    pkgs.openrgb
    # dev
    pkgs.arduino
  ];

  modules = {
    device = {
      cpu = "amd";
      gpu = "amd";
      drive = "nvme"; # where the os is installed
      supportsBrightness = false;
      supportsBluetooth = true;
    };
    shell = {
      git.enable = true;
      gpg.enable = true;
      passwords.enable = true;
    };
    services.greetd.enable = true;
    hardware.filesystem.zfs.enable = true;
    desktop = {
      sway.enable = true; # this enables various other components
      gaming.enable = true;
      util.mpv.enable = true;
      apps = {
        thunar.enable = true;
        vscode.enable = true;
        zathura.enable = true;
      };
    };
  };
}
