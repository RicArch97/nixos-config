# Configuration for Git
{
  config,
  options,
  lib,
  ...
}: let
  gitConfig = config.modules.shell.git;
in {
  options.modules.shell.git = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Ricardo Steijn";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "ricardo.steijn97@gmail.com";
    };
    signCommits = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    sshKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/id_ed25519";
    };
    remoteUrl = lib.mkOption {
      type = lib.types.str;
      default = "github.com";
    };

    workAccount = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      userEmail = lib.mkOption {
        type = lib.types.str;
        default = "r.steijn@hde.nl";
      };
      signCommits = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      sshKeyPath = lib.mkOption {
        type = lib.types.str;
        default = "~/.ssh/id_ed25519_work";
      };
      remoteUrl = lib.mkOption {
        type = lib.types.str;
        default = "gitlab.hunterdouglas.com";
      };
    };
  };

  config = lib.mkIf (gitConfig.enable) {
    # home manager configuration
    home.manager.programs.git = {
      enable = true;
      userName = gitConfig.userName;
      userEmail = gitConfig.userEmail;
      ignores = ["/.vscode" "/.pio" "/__pycache__" ".envrc" ".direnv"];
      delta.enable = true;
      includes = lib.mkIf (gitConfig.workAccount.enable) [
        {
          contents = {
            user = {
              name = gitConfig.userName;
              email = gitConfig.workAccount.userEmail;
            };
            commit.gpgSign = gitConfig.workAccount.signCommits;
          };
          condition = "hasconfig:remote.*.url:git@${gitConfig.workAccount.remoteUrl}:*/**";
        }
      ];
    };
  };
}
