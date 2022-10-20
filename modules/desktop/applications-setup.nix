# Sets the default applications and XDG mimeapps
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  appsConf = config.modules.desktop.defaultApplications;
in {
  options.modules.desktop.defaultApplications = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    apps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          package = lib.mkOption {type = lib.types.package;};
          install = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          cmd = lib.mkOption {
            type = lib.types.either lib.types.str lib.types.path;
          };
          desktop = lib.mkOption {type = lib.types.str;};
        };
      }));
      description = "default (mime) applications";
    };
  };

  # configure default apps and mimeapps
  config = lib.mkIf (appsConf.enable) {
    # set default terminal and editor
    modules.desktop.apps.alacritty.enable = true;
    modules.desktop.apps.neovim.enable = true;

    # set term and editor as envvars as well
    env = {
      EDITOR = appsConf.apps.editor.desktop;
      TERM = appsConf.apps.terminal.desktop;
    };

    # add all default packages to user packages, if they should be installed manually
    home.packages = lib.filter (elem: elem != null) (lib.mapAttrsToList (name: value:
      if value.install
      then value.package
      else null)
    appsConf.apps);

    # set XDG mimeapps and associations
    home.manager.xdg.mimeApps = {
      enable = true;
      defaultApplications = with appsConf.apps;
        builtins.mapAttrs
        (name: value:
          if value ? desktop
          then ["${value.desktop}.desktop"]
          else value)
        {
          "image/png" = image-viewer;
          "image/jpg" = image-viewer;
          "image/jpeg" = image-viewer;
          "video/*" = video;
          "inode/directory" = file-manager;
          "text/html" = browser;
          "text/plain" = editor;
          "text/x-tex" = ide;
          "text/x-python" = ide;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "application/pdf" = pdf;
          "application/zip" = archive;
          "application/rar" = archive;
          "application/7z" = archive;
          "application/*tar" = archive;
          "application/x-bibtex" = ide;
          "applications/json" = editor;
          "applications/x-yaml" = editor;
        };
    };
  };
}
