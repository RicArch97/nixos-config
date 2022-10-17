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
        default = "Orchis-Grey-Dark-Compact";
      };
    };
    iconTheme = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.tela-circle-icon-theme.override {colorVariants = ["grey"];};
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Tela-circle-grey-dark";
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

      # Systemwide GTK theming (e.g. for greetd)
      environment = {
        systemPackages = [
          gtkConfig.theme.package
          gtkConfig.iconTheme.package
          gtkConfig.cursorTheme.package
        ];
        etc."xdg/gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-cursor-theme-name=${gtkConfig.cursorTheme.name}
          gtk-cursor-theme-size=${toString gtkConfig.cursorTheme.size}
          gtk-font-name=${fontConfig.main.family} ${toString fontConfig.main.size}
          gtk-icon-theme-name=${gtkConfig.iconTheme.name}
          gtk-theme-name=${gtkConfig.theme.name}
        '';
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
