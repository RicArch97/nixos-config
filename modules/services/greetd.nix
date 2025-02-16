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
  passwordConfig = config.modules.shell.passwords;
  device = config.modules.device;
  fontConfig = config.modules.desktop.themes.fonts.styles;
in {
  options.modules.services.greetd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (greetdConfig.enable) {
    # Sway is used to run regreet,
    # independent from whether Sway is used as desktop window manager
    programs.sway = lib.mkIf (!swayConfig.enable) {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    # unlock GPG keyring upon login or/and enable gnome keyring upon login
    security.pam.services.greetd = {
      enableGnomeKeyring = lib.mkIf (passwordConfig.enable && passwordConfig.gnome-keyring.enable) true;
      gnupg.enable = lib.mkIf (gpgConfig.enable) true;
    };

    programs.regreet = {
      enable = true;
      theme = {
        name = gtkConfig.theme.name;
        package = gtkConfig.theme.package;
      };
      font = {
        name = fontConfig.main.family;
        size = fontConfig.main.size;
        package = pkgs.custom.product-sans;
      };
      iconTheme = {
        name = gtkConfig.iconTheme.name;
        package = gtkConfig.iconTheme.package;
      };
      cursorTheme = {
        name = gtkConfig.cursorTheme.name;
        package = gtkConfig.cursorTheme.package;
      };
      settings = {
        background = {
          path = "${config.nixosConfig.configDir}/wallpaper.jpg";
          fit = "Cover";
        };
      };
    };

    services.greetd.settings.default_session.command = let
      greetdSwayConfig = pkgs.writeText "greetd-sway-config" (
        ''
          exec "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
          exec "${lib.getExe config.programs.regreet.package}; swaymsg exit"

          xwayland disable

          bindsym Mod4+shift+e exec swaynag \
            -t warning \
            -m 'What do you want to do?' \
            -b 'Poweroff' 'systemctl poweroff' \
            -b 'Reboot' 'systemctl reboot'

          seat seat0 xcursor_theme ${gtkConfig.cursorTheme.name} ${toString gtkConfig.cursorTheme.size}

          output * bg "${config.nixosConfig.configDir}/wallpaper.jpg" fill
        ''
        + lib.optionalString (!device.hasTouchpad) ''
          input * accel_profile flat

        ''
        + lib.optionalString (device.name == "North" || device.name == "X570AM") ''
          output DP-2 pos 0 0 mode 2560x1440@165Hz
          output DP-1 pos 2560 0 mode 3440x1440@160Hz
        ''
      );
    in "sway --config ${greetdSwayConfig}";
  };
}
