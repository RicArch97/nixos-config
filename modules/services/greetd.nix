{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  greetdConfig = config.modules.services.greetd;
  gtkConfig = config.modules.desktop.themes.gtk;
  swayConfig = config.modules.desktop.sway;
  gpgConfig = config.modules.shell.gpg;
  zshConfig = config.modules.shell.zsh;
  device = config.modules.device;
  fontConfig = config.modules.desktop.themes.fonts.styles;
  colorScheme = config.modules.desktop.themes.colors;
in {
  options.modules.services.greetd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (greetdConfig.enable) {
    # Sway is used to run gtkgreet,
    # independent from whether Sway is used as desktop window manager
    programs.sway = lib.mkIf (!swayConfig.enable) {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    # install GTK themes systemwide
    environment.systemPackages = [pkgs.greetd.gtkgreet];

    # unlock GPG keyring upon login
    security.pam.services.greetd.gnupg = lib.mkIf (gpgConfig.enable) {
      enable = true;
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session.command = let
          gtkgreetStyle = pkgs.writeText "greetd-gtkgreet.css" ''
            window {
              background-size: cover;
              background-repeat: no-repeat;
              background-position: center;
              background-image: url("${config.nixosConfig.configDir}/wallpaper.jpg");
            }

            #body > box > box > label {
              text-shadow: 0 0 3px ${colorScheme.types.border};
              color: ${colorScheme.types.foreground};
            }

            entry {
              color: ${colorScheme.types.foreground};
              background: ${colorScheme.types.background-darker};
              border-radius: 10px;
              box-shadow: 0 0 5px ${colorScheme.types.border};
            }

            #clock {
              color: ${colorScheme.types.foreground};
              text-shadow: 0 0 3px ${colorScheme.types.border};
            }

            .text-button { border-radius: 10px; }
          '';
          greetdSwayConfig = pkgs.writeText "greetd-sway-config" (
            ''
              exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s ${gtkgreetStyle}; swaymsg exit"

              xwayland disable

              bindsym Mod4+shift+e exec swaynag \
                -t warning \
                -m 'What do you want to do?' \
                -b 'Poweroff' 'systemctl poweroff' \
                -b 'Reboot' 'systemctl reboot'

              seat seat0 xcursor_theme ${gtkConfig.cursorTheme.name} ${toString gtkConfig.cursorTheme.size}

              exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
            ''
            + lib.optionalString (!device.hasTouchpad) ''
              input * accel_profile flat

            ''
            + lib.optionalString (device.name == "X570AM") ''
              output DP-2 pos 0 0 mode 2560x1440@165Hz
              output DP-1 pos 2560 0 mode 3440x1440@160Hz
            ''
          );
        in "${pkgs.sway}/bin/sway --config ${greetdSwayConfig}";
      };
    };

    environment.etc."greetd/environments".text = let
      shell =
        if zshConfig.enable
        then "zsh"
        else "bash";
    in ''
      sway
      ${shell}
    '';
  };
}
