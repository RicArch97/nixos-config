# Configuration for EWW (Elkowar's Wacky Widgets)
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  ewwConfig = config.modules.desktop.util.eww;
  colorScheme = config.modules.desktop.themes.colors;
  fontConfig = config.modules.desktop.themes.fonts.styles;
in {
  options.modules.desktop.util.eww = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.eww;
    };
  };

  config = let
    # used in scripts
    dependencies = [
      pkgs.bash
      pkgs.sway
      pkgs.coreutils
      pkgs.findutils
      pkgs.gawk
      pkgs.gnused
      pkgs.psmisc
      pkgs.procps
      pkgs.jq
      pkgs.networkmanager
      pkgs.bluez
      pkgs.wireplumber
      pkgs.pulseaudio
    ];
  in
    lib.mkIf ewwConfig.enable {
      user.packages = dependencies;

      # home manager configuration
      home.manager = {
        programs.eww = {
          enable = true;
          package = ewwConfig.package;
          configDir = "${config.nixosConfig.configDir}/eww";
        };
        # systemd user service for the daemon
        systemd.user.services.eww-daemon = {
          Unit = {
            Description = "Eww Daemon";
            PartOf = ["graphical-session.target"];
          };
          Service = {
            Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
            ExecStart = "${ewwConfig.package}/bin/eww daemon --no-daemonize";
            Restart = "on-failure";
          };
          Install.WantedBy = ["graphical-session.target"];
        };
      };

      # colors and fonts to be used by the other EWW files
      # it only makes sense to this declarative, the rest is symlinked
      home.configFile = {
        "eww/src/scss/_colors.scss".text = ''
          $background: ${colorScheme.types.background};
          $background-darker: ${colorScheme.types.background-darker};
          $border: ${colorScheme.types.border};
          $foreground: ${colorScheme.types.foreground};
          $highlight: ${colorScheme.types.highlight};
          $selection: ${colorScheme.types.selection};

          $keyword: ${colorScheme.syntax.keyword};
          $variable: ${colorScheme.syntax.variable};
          $label: ${colorScheme.syntax.label};
          $function: ${colorScheme.syntax.function};
          $string: ${colorScheme.syntax.string};

          $warning: ${colorScheme.diagnostic.warning};
          $error: ${colorScheme.diagnostic.error};
        '';
        "eww/src/scss/_fonts.scss".text = ''
          $main-font-family: "${fontConfig.main.family}";
          $main-font-size: "${fontConfig.main.size}px";
          $sub-font-family: "${fontConfig.sub.family}";
          $sub-font-size: "${fontConfig.sub.size}px";
          $icon-font-family: "${fontConfig.icons.family}";
        '';
      };
    };
}
