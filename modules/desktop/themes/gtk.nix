# Configuration for GTK theming
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  gtkConfig = config.modules.desktop.themes.gtk;
  fontConfig = config.modules.desktop.themes.fonts.styles;
  device = config.modules.device;
in {
  options.modules.desktop.themes.gtk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    gsettings.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    theme = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.orchis-theme.override {
          border-radius = 12;
          tweaks = ["black"];
        };
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Orchis-Grey-Dark-Compact";
      };
    };
    iconTheme = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.papirus-icon-theme.override {color = "grey";};
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Papirus-Dark";
      };
    };
    cursorTheme = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.bibata-cursors;
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Bibata-Original-Classic";
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = 24;
      };
    };
  };

  config = lib.mkIf (gtkConfig.enable) (lib.mkMerge [
    {
      # Used by lots of GTK / Gnome apps
      programs.dconf.enable = true;

      # Enable org.a11y.Bus required by some GTK / Gnome apps
      services.gnome.at-spi2-core.enable = true;

      # install default adwaita theme for fallback,
      # add themes to system packages for greeters
      environment.systemPackages = [
        pkgs.gnome.gnome-themes-extra
        gtkConfig.theme.package
        gtkConfig.iconTheme.package
        gtkConfig.cursorTheme.package
      ];

      # home manager configuration
      home.manager.gtk = {
        enable = true;
        theme = {
          package = gtkConfig.theme.package;
          name = gtkConfig.theme.name;
        };
        iconTheme = {
          package = gtkConfig.iconTheme.package;
          name = gtkConfig.iconTheme.name;
        };
        cursorTheme = {
          package = gtkConfig.cursorTheme.package;
          name = gtkConfig.cursorTheme.name;
          size = gtkConfig.cursorTheme.size;
        };
        # font package installed through global font config
        font = {
          name = fontConfig.main.family;
          size = fontConfig.main.size;
        };
      };

      home.manager.home.pointerCursor = {
        package = gtkConfig.cursorTheme.package;
        name = gtkConfig.cursorTheme.name;
        size = gtkConfig.cursorTheme.size;
        x11.enable = lib.mkIf (device.displayProtocol == "x11") true;
      };
    }

    (lib.mkIf (gtkConfig.gsettings.enable) {
      # make this globally available so it can be used by gtkgreet
      home.packages = let
        configure-gtk = pkgs.writeShellScriptBin "configure-gtk" ''
          gnome_schema=org.gnome.desktop.interface

          gsettings set $gnome_schema gtk-theme '${gtkConfig.theme.name}'
          gsettings set $gnome_schema icon-theme '${gtkConfig.iconTheme.name}'
          gsettings set $gnome_schema cursor-theme '${gtkConfig.cursorTheme.name}'
          gsettings set $gnome_schema cursor-size '${toString gtkConfig.cursorTheme.size}'
          gsettings set $gnome_schema font-name '${fontConfig.main.family} ${toString fontConfig.main.size}'
        '';
      in [configure-gtk pkgs.glib];
    })
  ]);
}
