/*
North - Fully watercooled black, gold and wood build for work and gaming.

AsRock X670E Taichi motherboard
AMD Ryzen 9 7950X3D processor
Nvidia GeForce RTX 4090 graphics card
64 GB DDR5 RAM
Multiple NVMe drives

Used with multi monitor setup.
*/
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable OpenRGB for LED control
  services.hardware.openrgb.enable = true;

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
    pkgs.teams-for-linux
    pkgs.slack
    pkgs.fastfetch
  ];

  modules = {
    device = {
      cpu = "amd";
      gpu = "nvidia";
      drive = "nvme";
      supportsBrightness = false;
      supportsBluetooth = true;
      monitors = {
        main = {
          name = "DP-1";
          resolution = "3440x1440";
          position = {
            x = 2560;
            y = 0;
          };
          refresh_rate = 160;
          adaptive_sync = true;
          primary = true;
        };
        side = {
          name = "DP-2";
          resolution = "2560x1440";
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
      git = {
        enable = true;
        signCommits = true;
        workAccount = {
          enable = true;
          signCommits = true;
        };
      };
      gpg.enable = true;
      passwords.enable = true;
    };
    virtualisation.docker.enable = true;
    desktop = {
      labwc.enable = true;
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
        tools.nrf.enable = true;
      };
    };
  };
}
