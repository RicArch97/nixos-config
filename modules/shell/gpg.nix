# Configuration for gpg
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  gpgConfig = config.modules.shell.gpg;
  passwordConfig = config.modules.shell.passwords;
in {
  options.modules.shell.gpg = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = passwordConfig.enable;
    };
    cacheTtl = {
      default = lib.mkOption {
        type = lib.types.int;
        default = 3600;
      };
      max = lib.mkOption {
        type = lib.types.int;
        default = 86400;
      };
    };
  };

  config = lib.mkIf (gpgConfig.enable) {
    # for gnome3 pinentry
    services.dbus.packages = [pkgs.gcr];

    # home manager configuration
    home.manager.programs.gpg.enable = true;
    home.manager.services.gpg-agent = {
      enable = true;
      defaultCacheTtl = gpgConfig.cacheTtl.default;
      maxCacheTtl = gpgConfig.cacheTtl.max;
      pinentryFlavor = "gnome3";
      extraConfig = ''
        allow-preset-passphrase
      '';
    };
  };
}
