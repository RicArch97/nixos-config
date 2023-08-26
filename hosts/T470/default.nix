/*
T470 - Personal laptop.

Lenovo ThinkPad T470
Intel i5-7200U processor
Intel graphics 620 GPU
Intel Wi-Fi 6E AX210 vPro Wi-Fi and Bluetooth chip
8 GB RAM
Samsung EVO 970 1TB SSD

This system is used for programming / writing documents.
Should not contain any gaming related stuff.
*/
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  # power management
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [acpi_call];
    kernelModules = ["acpi_call"];
    # this device has a kaby lake CPU, from nixos-hardware (both power saving features)
    kernelParams = [
      "i915.enable_fbc=1"
      "i915.enable_psr=2"
    ];
  };

  # thinkpad trackpoint
  hardware.trackpoint.enable = true;
  hardware.trackpoint.emulateWheel = true;

  # specific services
  services = {
    # this device should be able to send docs to a printer
    printing.enable = true;
    # power management daemon
    tlp = {
      enable = true;
      settings = {
        USB_AUTOSUSPEND = 0;
      };
    };
  };

  # host specific user packages
  home.packages = [
    # multimedia
    pkgs.gimp
    # utils
    pkgs.neofetch
    # dev
    pkgs.arduino
  ];

  modules = {
    device = {
      cpu = "intel";
      gpu = "intel";
      drive = "ssd"; # where the os is installed
      hasTouchpad = true;
      hasFingerprint = false; # requires specific drivers, disable for now
      supportsBrightness = true;
      supportsBluetooth = true;
      bigScreen = false;
      monitors = {
        main = {
          x11_name = "eDP-1";
          wayland_name = "eDP-1";
          resolution = "192x1080";
          position = {
            x = 0;
            y = 0;
          };
          refresh_rate = 60;
          adaptive_sync = false;
          primary = true;
        };
      };
    };
    shell = {
      git.enable = true;
      gpg.enable = true;
      passwords.enable = true;
    };
    services.greetd.enable = true;
    hardware.filesystem.zfs.enable = true;
    desktop = {
      sway.enable = true;
      util.mpv.enable = true;
      apps = {
        browsers = {
          chrome.enable = true;
          firefox.setDefault = false;
        };
        discord.enable = true;
        thunar.enable = true;
        vscode.enable = true;
        zathura.enable = true;
      };
    };
  };
}
