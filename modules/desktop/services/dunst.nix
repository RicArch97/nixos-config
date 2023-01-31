# Dunst notification daemon configuration
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  dunstConfig = config.modules.desktop.services.dunst;
  colorScheme = config.modules.desktop.themes.colors;
  gtkConfig = config.modules.desktop.themes.gtk;
  fontConfig = config.modules.desktop.themes.fonts.styles;
  defaultApps = config.modules.desktop.defaultApplications.apps;
in {
  options.modules.desktop.services.dunst = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (dunstConfig.enable) {
    # hicolor is the fallback theme
    home.packages = [pkgs.libnotify pkgs.hicolor-icon-theme];

    # home manager configuration
    home.manager.services.dunst = {
      enable = true;
      package = pkgs.dunst;
      iconTheme = {
        name = gtkConfig.iconTheme.name;
        package = gtkConfig.iconTheme.package;
      };
      settings = let
        ct = colorScheme.types;
        cc = colorScheme.colors;
      in {
        global = {
          follow = "mouse";
          width = 350;
          height = 350;
          origin = "bottom-right";
          offset = "24x24";

          progress_bar = true;
          progress_bar_height = 14;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 350;

          indicate_hidden = true;

          separator_height = 6;
          separator_color = "frame";
          padding = 16;
          horizontal_padding = 16;
          # border around notification
          frame_width = 0;
          corner_radius = 12;

          sort = true;
          idle_threshold = 0;

          layer = "top";
          force_xwayland = false;

          font = "${fontConfig.main.family} ${toString fontConfig.main.size}";
          line_height = 0;
          markup = "full";
          format = ''<b>%a</b>\n%s'';
          alignment = "left";
          vertical_alignment = "center";
          word_wrap = true;

          show_age_threshold = 120;
          ignore_newline = false;
          stack_duplicates = false;
          hide_duplicate_count = false;
          show_indicators = true;

          min_icon_size = 80;
          max_icon_size = 90;

          sticky_history = true;
          history_length = 100;

          dmenu = "${defaultApps.menu.cmd} -p dunst";
          browser = "${defaultApps.browser.cmd} -new-tab";
          always_run_script = true;
          ignore_dbusclose = false;

          mouse_left_click = "do_action, close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };

        urgency_low = {
          background = ct.background-darker;
          foreground = ct.foreground;
          frame_color = ct.border;
          timeout = 5;
        };

        urgency_normal = {
          background = ct.background-darker;
          foreground = ct.foreground;
          frame_color = ct.border;
          timeout = 8;
        };

        urgency_critical = {
          background = ct.background-darker;
          foreground = ct.foreground;
          frame_color = cc.color1; #red
          timeout = 0;
        };

        volume = {
          summary = "Volume*";
          highlight = ct.highlight;
        };

        backlight = {
          appname = "Backlight";
          highlight = ct.highlight;
        };
      };
    };
    # icons for volume, brightness etc.
    home.configFile."dunst/icons" = {
      source = "${config.nixosConfig.configDir}/dunst/icons";
      recursive = true;
    };
  };
}
