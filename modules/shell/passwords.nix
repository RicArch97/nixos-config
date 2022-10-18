# Configuration for password storage
{
  config,
  options,
  pkgs,
  lib,
  ...
}: let
  passwordConfig = config.modules.shell.passwords;
  device = config.modules.device;
in {
  options.modules.shell.passwords = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (passwordConfig.enable) {
    home.manager = {
      programs.password-store = {
        enable = true;
        package = let
          passpkg =
            if device.displayProtocol == "wayland"
            then pkgs.pass-wayland
            else pkgs.pass;
        in
          passpkg.withExtensions (exts: [
            exts.pass-otp
            exts.pass-genphrase
            exts.pass-tomb
          ]);
      };
      # Libsecret D-Bus API with pass as backend to let apps authenticate
      services.pass-secret-service.enable = true;
    };
  };
}
