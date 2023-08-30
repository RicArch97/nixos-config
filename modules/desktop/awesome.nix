# Configuration for the Awesome window manager
{
  inputs,
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  awesomeConfig = config.modules.desktop.awesome;
  device = config.modules.device;
  defaultApps = config.modules.desktop.defaultApplications.apps;
  colorScheme = config.modules.desktop.themes.colors;
  fontConfig = config.modules.desktop.themes.fonts.styles;
  gtkConfig = config.modules.desktop.themes.gtk;
in {
  options.modules.desktop.awesome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (awesomeConfig.enable) {
    # set display protocol to X11 for some specifics
    modules.device.displayProtocol = "x11";

    # extra utilities required for normal use
    home.packages = [pkgs.xclip];

    # XDG portal for GTK apps
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    # brightness support
    programs.light.enable = lib.mkIf (device.supportsBrightness) true;

    # some default X utility apps
    modules.desktop.defaultApplications.apps = {
      screenshot = rec {
        package = pkgs.scrot;
        cmd = "${package}/bin/scrot";
        desktop = "scrot";
      };
      image-viewer = rec {
        package = pkgs.imv;
        cmd = "${package}/bin/imv";
        desktop = "imv";
      };
    };

    # application launcher
    modules.desktop.util.rofi = {
      enable = true;
      menu.enable = true;
    };

    # polkit auth agent for GUI authentication
    modules.desktop.services.polkit.enable = true;

    services.xserver = {
      enable = true;
      exportConfiguration = true;

      # xorg.conf monitor configuration
      # monitors are mapped from left to right by the module
      # hence, we need to sort the list based on our X positions
      xrandrHeads = let
        monitorsList = lib.attrValues device.monitors;
        sortedMonitors = lib.sort (a: b: a.position.x < b.position.x) monitorsList;
      in
        builtins.map (monitor: {
          output = monitor.x11_name;
          monitorConfig = let
            mode = "${monitor.resolution}_${toString monitor.refresh_rate}";
          in
            if monitor.modeline != null
            then ''
              Modeline "${mode}" ${monitor.modeline}
              Option "PreferredMode" "${mode}"
            ''
            else ''
              Option "PreferredMode" "${monitor.resolution}"
            '';
          primary = monitor.primary;
        })
        sortedMonitors;

      # enable variable refresh rate if the primary monitor has it set
      deviceSection =
        lib.mkIf (lib.any (
          monitor: monitor.adaptive_sync && monitor.primary
        ) (lib.attrValues device.monitors)) ''
          Option "VariableRefresh" "true"
          Option "AsyncFlipSecondaries" "true"
        '';

      # disable mouse acceleration
      libinput = {
        enable = true;
        mouse = {
          accelProfile = "flat";
          accelSpeed = "0";
        };
      };

      # use custom awesome
      windowManager.awesome = {
        enable = true;
        package = pkgs.awesome-luajit-git;
        luaModules = [
          pkgs.luajitPackages.lgi
          pkgs.luajitPackages.ldbus
          pkgs.luajitPackages.luadbi-mysql
          pkgs.luajitPackages.luaposix
          pkgs.custom.lua-dbus-proxy
          pkgs.custom.async-lua
          pkgs.custom.lgi-async-extra
        ];
      };

      # lightdm display manager
      displayManager.lightdm = {
        enable = true;
        background = "${config.nixosConfig.configDir}/wallpaper.jpg";
        greeters.gtk = {
          enable = true;
          theme = {
            name = gtkConfig.theme.name;
            package = gtkConfig.theme.package;
          };
          iconTheme = {
            name = gtkConfig.iconTheme.name;
            package = gtkConfig.iconTheme.package;
          };
          cursorTheme = {
            name = gtkConfig.cursorTheme.name;
            package = gtkConfig.cursorTheme.package;
          };
          indicators = [
            "~host"
            "~spacer"
            "~clock"
            "~spacer"
            "~session"
            "~power"
          ];
        };
      };
    };

    # link awesome Lua config files
    home.configFile = {
      "awesome" = {
        source = "${config.nixosConfig.configDir}/awesome";
        recursive = true;
      };
      "awesome/globals.lua" = {
        text = ''
          -------------------------------------------------
          -- Global variables used throughout the config --
          -------------------------------------------------

          modkey = "Mod4"
          terminal = "${defaultApps.terminal.cmd}"
          file_manager = "${defaultApps.file-manager.cmd}"
          browser = "${defaultApps.browser.cmd}"
          editor = "${defaultApps.editor.cmd}"
          visual_editor = "${defaultApps.ide.cmd}"
          launcher = "${defaultApps.menu.cmd}"
        '';
      };
    };

    # awesome code intellisense, link to a known location so
    # it can be defined in a .vscode/settings.json file
    home.file.".local/share/awesome-code-doc" = {
      source = inputs.awesome-code-doc;
      recursive = true;
    };
  };
}
