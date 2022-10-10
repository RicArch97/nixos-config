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
        default = pkgs.orchis-theme.override {tweaks = ["black"];};
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Orchis-grey-dark-compact";
      };
    };
    iconTheme = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.tela-circle-icon-theme;
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Tela-circle-black-dark";
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
      # install default adwaita theme for fallback
      home.packages = [pkgs.gnome.gnome-themes-extra];

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

      # XDG spec cursor theme
      home.file.".local/share/icons/default/index.theme".text = ''
        [icon theme]
        Name=Default
        Comment=Default Cursor Theme
        Inherits=${gtkConfig.cursorTheme.name}
      '';
    }

    (lib.mkIf (gtkConfig.gsettings.enable) {
      # GSettings API backend
      programs.dconf.enable = true;
      # make this globally available so it can be used by gtkgreet
      environment.systemPackages = let
        set-gsettings = let
          schema = pkgs.gsettings-desktop-schemas;
          datadir = "${schema}/share/gsettings-schemas/${schema.name}";
        in
          pkgs.writeShellScriptBin "set-gsettings" ''
            export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
            gnome_schema=org.gnome.desktop.interface

            gsettings set $gnome-schema gtk-theme '${gtkConfig.theme.name}'
            gsettings set $gnome-schema icon-theme '${gtkConfig.iconTheme.name}'
            gsettings set $gnome-schema cursor-theme '${gtkConfig.cursorTheme.name}'
            gsettings set $gnome-schema cursor-size '${toString gtkConfig.cursorTheme.size}'
            gsettings set $gnome-schema font-name '${fontConfig.main.family} ${toString fontConfig.main.size}'
          '';
      in [
        set-gsettings
        pkgs.gsettings-desktop-schemas
        pkgs.glib
      ];
    })
  ]);
}
