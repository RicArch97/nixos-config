/*
T470 - University and office laptop.

Lenovo ThinkPad T470
Intel i5-7200U processor
Intel graphics 620 GPU
Intel Wi-Fi 6E AX210 vPro Wi-Fi and Bluetooth chip
8 GB RAM
Samsung EVO 970 1TB SSD

This system is used for programming.
Should not contain any gaming related stuff.
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

  boot.initrd = {
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

  user.packages = [
    # multimedia
    inputs.webcord.packages.${pkgs.system}.default
    pkgs.spotify
    pkgs.gimp
    pkgs.gimpPlugins.resynthesizer
    # utils
    pkgs.neofetch
  ];

  modules = {
    device = {
      cpu = "intel";
      gpu = "intel";
      drive = "ssd"; # where the os is installed
      hasTouchpad = true;
      supportsBrightness = true;
      supportsBluetooth = true;
      bigScreen = false;
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
      util.mpv.enable = true;
      apps = {
        thunar.enable = true;
        vscode.enable = true;
        zathura.enable = true;
      };
    };
  };
}
