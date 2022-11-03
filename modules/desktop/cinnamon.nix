# Configuration for the Cinnamon desktop environment
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  cinnamonConfig = config.modules.desktop.cinnamon;
  device = config.modules.device;
in {
  options.modules.desktop.cinnamon = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (cinnamonConfig.enable) {
    # set display protocol to X11 for some specifics
    modules.device.displayProtocol = "x11";

    # use PipeWire
    hardware.pulseaudio.enable = false;

    # use home manager settings for QT
    qt5.enable = lib.mkForce false;

    # cinnamon image viewer, file manager and archive
    modules.desktop.defaultApplications.apps = {
      image-viewer = rec {
        package = pkgs.cinnamon.xviewer;
        cmd = "${package}/bin/xviewer";
        desktop = "xviewer";
      };
      file-manager = rec {
        package = pkgs.cinnamon.nemo;
        cmd = "${package}/bin/nemo";
        install = false; # installed by cinnamon module
        desktop = "nemo";
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
      displayManager = {
        lightdm.enable = true;
        defaultSession = "cinnamon";
      };
      desktopManager.cinnamon.enable = true;
    };

    # power management abstraction layer
    services.upower.enable = lib.mkIf (device.name == "T470") true;

    home.packages = [
      pkgs.gettext
      pkgs.gnome.gnome-screenshot
      pkgs.zip
      pkgs.unzip
    ];
  };
}
