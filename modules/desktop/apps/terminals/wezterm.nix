# Configuration for the Wezterm terminal
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  wezConfig = config.modules.desktop.apps.terminals.wezterm;
  colorScheme = config.modules.desktop.themes.colors;
  fontStyles = config.modules.desktop.themes.fonts.styles;
  device = config.modules.device;
in {
  options.modules.desktop.apps.terminals.wezterm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (wezConfig.enable) {
    modules.desktop.defaultApplications.apps.terminal = rec {
      package = pkgs.wezterm;
      install = false; # installed by home manager
      cmd = "${package}/bin/wezterm";
      desktop = "wezterm";
    };

    # home manager configuration
    home.manager.programs.wezterm = {
      enable = true;
      colorSchemes = let
        cc = colorScheme.colors;
        ct = colorScheme.types;
      in {
        githubDark = {
          background = ct.background-darker;
          foreground = ct.foreground;
          selection_fg = ct.foreground;
          selection_bg = ct.selection;
          cursor_bg = ct.foreground;
          cursor_border = ct.border;
          split = ct.border;
          ansi = [
            cc.color0
            cc.color1
            cc.color2
            cc.color3
            cc.color4
            cc.color5
            cc.color6
            cc.color7
          ];
          brights = [
            cc.color8
            cc.color9
            cc.color10
            cc.color11
            cc.color12
            cc.color13
            cc.color14
            cc.color15
          ];
        };
      };
      extraConfig = let
        monitorsList = lib.attrValues device.monitors;
        refreshRates = builtins.map (monitor: monitor.refresh_rate) monitorsList;
        # max fps depends the monitor with the lowest refresh rate
        # on Wayland the compositor provides the refresh per monitor
        maxFps = lib.foldl (a: b:
          if a < b
          then a
          else b) (lib.head refreshRates) (lib.tail refreshRates);
      in ''
        local config = {}
        if wezterm.config_builder then
          config = wezterm.config_builder()
        end

        local function window_padding(x, y)
          return {
            left = x,
            right = x,
            top = y,
            bottom = y
          }
        end

        -- general settings
        config.max_fps = ${toString maxFps}
        config.scrollback_lines = 10000
        config.bold_brightens_ansi_colors = "BrightAndBold"
        config.audible_bell = "Disabled"

        -- window settings
        config.window_padding = window_padding(10, 10)
        config.enable_tab_bar = false
        config.initial_cols = 180
        config.initial_rows = 45

        -- cursor settings
        config.default_cursor_style = "SteadyUnderline"

        -- font settings
        config.font = wezterm.font("${fontStyles.mono.family}")
        config.font_size = ${toString fontStyles.mono.size}

        -- colorscheme
        config.color_scheme = "githubDark"

        return config
      '';
    };
  };
}
