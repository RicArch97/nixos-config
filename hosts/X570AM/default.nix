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
  imports = [
    ./hardware-configuration.nix
  ];

  time.timezone = "Europe/Amsterdam";

  boot = {
    # allows to interact with the SMBus on Gigabyte boards, for OpenRGB
    kernelParams = ["acpi_enforce_resources=lax"];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "dm_mod"
      ];
      kernelModules = [
        "sd_mod"
        "dm_mod"
      ];
    };
  };

  user.packages = [
    # multimedia
    inputs.webcord.packages.${pkgs.system}.default
    pkgs.spotify
    pkgs.gimp
    pkgs.gimpPlugins.resynthesizer
    # utils
    pkgs.openrgb
    pkgs.neofetch
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
    hardware.storage.zfs.enable = true;
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
