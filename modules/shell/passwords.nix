# Configuration for password storage
{
  config,
  options,
  pkgs,
  lib,
  ...
}: let
  passwordConfig = config.modules.shell.passwords;
  gitConfig = config.modules.shell.git;
  device = config.modules.device;
in {
  options.modules.shell.passwords = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    gnome-keyring.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    pass.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (passwordConfig.enable) (lib.mkMerge [
    {
      home.manager.programs.ssh = {
        enable = true;
        addKeysToAgent = "yes";
        matchBlocks = lib.mkIf (gitConfig.enable) {
          "${gitConfig.remoteUrl}" = {
            hostname = gitConfig.remoteUrl;
            user = "git";
            identityFile = gitConfig.sshKeyPath;
            identitiesOnly = true;
          };
          "${gitConfig.workAccount.remoteUrl}" = lib.mkIf (gitConfig.workAccount.enable) {
            hostname = gitConfig.workAccount.remoteUrl;
            user = "git";
            identityFile = gitConfig.workAccount.sshKeyPath;
            identitiesOnly = true;
          };
        };
      };
    }

    (lib.mkIf (passwordConfig.pass.enable && !passwordConfig.gnome-keyring.enable) {
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

        home.manager.services.ssh-agent.enable = true;
      };
    })

    (lib.mkIf (passwordConfig.gnome-keyring.enable && !passwordConfig.pass.enable) {
      home.manager.services.gnome-keyring = {
        enable = true;
        components = ["pkcs11" "secrets" "ssh"];
      };

      # set SSH_AUTH_SOCK to expose the gnome-keyring ssh agent
      env.SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    })
  ]);
}
