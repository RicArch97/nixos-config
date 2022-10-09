# Configuration for Zathura PDF viewer
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  zatConfig = config.modules.desktop.apps.zathura;
  colorScheme = config.modules.desktop.themes.colors;
  fontStyles = config.modules.desktop.themes.fonts.styles;
in {
  options.modules.desktop.apps.zathura = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (zatConfig.enable) {
    modules.desktop.defaultApplications.apps.pdf = rec {
      package = pkgs.zathura;
      install = false; # installed by home manager
      cmd = "${package}/bin/zathura";
      desktop = "org.pwmt.zathura";
    };

    # home manager configuration
    home.manager.programs.zathura = {
      enable = true;
      package = pkgs.zathura;
      options = let
        ct = colorScheme.types;
        cs = colorScheme.syntax;
        cd = colorScheme.diagnostic;
      in {
        guioptions = "";
        adjust-open = "best-fit";
        window-title-home-tilde = true;
        statusbar-home-tilde = true;
        selection-clipboard = "clipboard";

        font = "${fontStyles.mono.family} 10";

        notification-error-bg = cd.error;
        notification-error-fg = ct.foreground;
        notification-warning-bg = cd.warning;
        notification-warning-fg = ct.selection;
        notification-bg = ct.background;
        notification-fg = ct.foreground;

        completion-bg = ct.background;
        completion-fg = cs.comment;
        completion-group-bg = ct.background;
        completion-group-fg = cs.comment;
        completion-highlight-bg = ct.selection;
        completion-highlight-fg = ct.foreground;

        index-bg = ct.background;
        index-fg = ct.foreground;
        index-active-bg = ct.current-line;
        index-active-fg = ct.foreground;

        inputbar-bg = ct.background;
        inputbar-fg = ct.foreground;
        statusbar-bg = ct.background;
        statusbar-fg = ct.foreground;

        highlight-color = ct.highlight;
        highlight-active-color = ct.selection;

        default-bg = ct.background;
        default-fg = ct.foreground;

        render-loading = true;
        render-loading-bg = ct.foreground;
        render-loading-fg = ct.background;

        recolor = true;
        recolor-lightcolor = ct.background;
        recolor-darkcolor = ct.foreground;
      };
      extraConfig = ''
        map <C-Tab> toggle_statusbar
      '';
    };
  };
}
