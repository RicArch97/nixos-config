# Configuration for ZSH
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  zshConfig = config.modules.shell.zsh;
  colorScheme = config.modules.desktop.themes.colors;
in {
  options.modules.shell.zsh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (zshConfig.enable) {
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
    environment.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
    environment.pathsToLink = ["/share/zsh"];

    home.packages = [
      pkgs.zsh-autocomplete
      pkgs.pure-prompt
      # download stuff via the terminal
      pkgs.wget
      pkgs.curl
      # global binary script dependencies
      pkgs.coreutils
      pkgs.gawk
      pkgs.psmisc
      pkgs.procps
      pkgs.gnugrep
      pkgs.bc
      pkgs.imagemagick
      # util
      pkgs.htop
    ];

    # home manger configuration
    home.manager.programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
      zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autocd = true;
        defaultKeymap = "viins";
        dotDir = ".config/zsh";
        history = rec {
          size = 1000000;
          save = size;
          path = "$XDG_DATA_HOME/zsh/zsh_history";
        };
        shellAliases = {
          "ls" = "ls -l --color=auto";
          "la" = "ls -la --color=auto";
          "rmdir" = "rm -r";
          "srmdir" = "sudo rm -r";
          "mkexe" = "chmod +x";
          "smkexe" = "sudo chmod +x";
          "open" = "$EDITOR";
          "sopen" = "sudo $EDITOR";
        };
        initExtra = let
          ct = colorScheme.types;
          cs = colorScheme.syntax;
          cd = colorScheme.diagnostic;
        in ''
          autoload -U promptinit; promptinit

          # prompt colors
          zstyle :prompt:pure:user color '${ct.foreground}'
          zstyle :prompt:pure:host color '${ct.foreground}'
          zstyle :prompt:pure:path color '${cs.label}'
          zstyle :prompt:pure:git:branch color '${cs.variable}'
          zstyle :prompt:pure:git:branch:cached color '${cd.error}'
          zstyle :prompt:pure:git:dirty color '${cd.warning}'
          zstyle :prompt:pure:git:action color '${cs.variable}'
          zstyle :prompt:pure:git:arrow color '${cs.string}'
          zstyle :prompt:pure:git:stash color '${cs.string}'
          zstyle :prompt:pure:git:execution_time color '${cs.comment}'
          zstyle :prompt:pure:git:suspended_jobs color '${cs.keyword}'
          zstyle :prompt:pure:virtualenv color '${cs.function}'
          zstyle :prompt:pure:prompt:error color '${cd.error}'
          zstyle :prompt:pure:prompt:success color '${ct.highlight}'
          zstyle :prompt:pure:prompt:continuation color '${cs.function}'

          # turn on git stash status
          zstyle :prompt:pure:git:stash show yes

          prompt pure
        '';
      };
    };
  };
}
