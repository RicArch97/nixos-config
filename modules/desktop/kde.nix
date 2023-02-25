# Configuration for the KDE desktop environment
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  kdeConfig = config.modules.desktop.kde;
  device = config.modules.device;
in {
  options.modules.desktop.kde = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (kdeConfig.enable) {
    # use KDE on wayland
    modules.device.displayProtocol = "wayland";
    env.NIXOS_OZONE_WL = "1";

    # use PipeWire
    hardware.pulseaudio.enable = false;

    # use KDE qt and gtk settings
    modules.desktop.themes.qt.enable = false;
    modules.desktop.themes.gtk.enable = false;
    # enable dconf
    programs.dconf.enable = true;

    modules.desktop.defaultApplications.apps = {
      image-viewer = rec {
        package = pkgs.libsForQt5.gwenview;
        cmd = "${package}/bin/gwenview";
        desktop = "gwenview";
      };
      file-manager = rec {
        package = pkgs.libsForQt5.dolphin;
        cmd = "${package}/bin/dolphin";
        install = false; # installed by kde module
        desktop = "dolphin";
      };
      archive = rec {
        package = pkgs.mate.engrampa;
        cmd = "${package}/bin/engrampa";
        desktop = "engrampa";
      };
    };

    services.xserver = {
      enable = true;
      libinput = {
        enable = true;
        mouse.accelProfile = "flat";
        touchpad.accelProfile = lib.mkIf (device.hasTouchpad) "flat";
      };
      displayManager.sddm.enable = true;
      desktopManager.plasma5 = {
        enable = true;
        useQtScaling = true;
      };
    };

    home.packages = [
      pkgs.zip
      pkgs.unzip
      # system theme
      pkgs.custom.orchis-kde-theme
      (pkgs.tela-circle-icon-theme.override
        {colorVariants = ["grey"];})
      pkgs.bibata-cursors
    ];
  };
}
