# Configuration for the LabWC wayland compositor
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  labwcConfig = config.modules.desktop.labwc;
  device = config.modules.device;
  defaultApps = config.modules.desktop.defaultApplications.apps;
  colorScheme = config.modules.desktop.themes.colors;
  fontConfig = config.modules.desktop.themes.fonts.styles;
  gtkConfig = config.modules.desktop.themes.gtk;
in {
  options.modules.desktop.labwc = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = let
    labwcRc = {
      core = {
        gap = 10;
        adaptiveSync = "yes";
        allowTearing = "yes";
        reuseOutputMode = "yes";
        xwaylandPersistence = "yes";
      };
      windowSwitcher = {
        _attrs = {
          outlines = "no";
        };
      };
      focus = {
        followMouse = "yes";
      };
      desktops = {
        _attrs = {number = "6";};
      };
      theme = {
        cornerRadius = 12;
        dropShadows = "yes";
        font = [
          {
            _attrs = {place = "ActiveWindow";};
            name = fontConfig.sub.family;
            size = fontConfig.sub.size;
            weight = "bold";
          }
          {
            _attrs = {place = "InactiveWindow";};
            name = fontConfig.sub.family;
            size = fontConfig.sub.size;
            weight = "normal";
          }
          {
            _attrs = {place = "MenuItem";};
            name = fontConfig.main.family;
            size = fontConfig.main.size;
          }
          {
            _attrs = {place = "OnScreenDisplay";};
            name = fontConfig.main.family;
            size = fontConfig.main.size;
          }
        ];
      };
      margin = {
        # basically outer gaps
        _attrs = {
          top = "10";
          bottom = "10";
          left = "10";
          right = "10";
        };
      };
      libinput.device = {
        _attrs = {category = "default";};
        naturalScroll = "no";
        leftHanded = "no";
        pointerSpeed = 0.0;
        accelProfile = "flat";
        middleEmulation = "no";
        disableWhileTyping = "no";
      };
      # keyboard = {
      #   keybind = [
      #     {
      #       _attrs = {key = "W-Return";};
      #       action._attrs = {
      #         name = "Execute";
      #         command = "${defaultApps.terminal.cmd}";
      #       };
      #     }
      #     {
      #       _attrs = {key = "W-d";};
      #       action._attrs = {
      #         name = "Execute";
      #         command = "${defaultApps.menu.cmd}";
      #       };
      #     }
      #   ];
      # };
    };
  in
    lib.mkIf (labwcConfig.enable) {
      programs.labwc.enable = true;

      # utilized packages in the config / util
      home.packages = [
        pkgs.swaybg
        pkgs.playerctl
        pkgs.pamixer
        pkgs.slurp
        pkgs.dex
        pkgs.wlclock
        pkgs.wl-clipboard
        pkgs.wlr-randr
        pkgs.xorg.xrandr
      ];

      # set display protocol to Wayland for some specifics
      modules.device.displayProtocol = "wayland";

      # XDG portals for screensharing etc
      xdg.portal = {
        enable = true;
        wlr = {
          enable = true;
          settings = {
            screencast = {
              chooser_type = "simple";
              chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
            };
          };
        };
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        config.common.default = ["wlr" "gtk"];
      };

      # some default apps used with Wayland / LabWC
      modules.desktop.defaultApplications.apps = {
        screenshot = rec {
          package = pkgs.grim;
          cmd = "${package}/bin/grim";
          desktop = "grim";
        };
        image-viewer = rec {
          package = pkgs.imv;
          cmd = "${package}/bin/imv";
          desktop = "imv";
        };
      };

      modules.desktop.util.rofi = {
        enable = true;
        menu.enable = true;
      };

      # for volume and brightness level notification
      modules.desktop.services.dunst.enable = true;

      # enable swayidle and gtklock modules
      modules.desktop.services.swayidle.enable = true;
      modules.desktop.util.gtklock.enable = true;

      # enable greetd as display manager
      modules.services.greetd.enable = true;

      # polkit auth agent for GUI authentication
      modules.desktop.services.polkit.enable = true;

      # make sure Electron apps use the Wayland backend by setting this flag
      env.NIXOS_OZONE_WL = "1";

      home.configFile."labwc/autostart".text = with device.monitors; let
        ct = colorScheme.types;

        adaptiveSyncSetting = monitor:
          if monitor.adaptive_sync
          then "enabled"
          else "disabled";

        systemd_variables = let
          variables_list = [
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "XDG_CURRENT_DESKTOP"
            "XDG_SESSION_TYPE"
            "NIXOS_OZONE_WL"
            "XCURSOR_THEME"
            "XCURSOR_SIZE"
          ];
        in
          lib.concatStringsSep " " variables_list;
      in
        ''
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${systemd_variables}
          ${pkgs.dex}/bin/dex -a -s ~/.config/autostart/

          set-wallpaper-wayland restore
          launch-wlclock '${main.name}' '${ct.background-darker}' '${ct.foreground}'
        ''
        + lib.optionalString (device.name == "North") ''
          ${pkgs.wlr-randr}/bin/wlr-randr ''
        + ''--output ${main.name} ''
        + ''--mode ${main.resolution}@${toString main.refresh_rate}Hz ''
        + ''--pos ${toString main.position.x},${toString main.position.y} ''
        + ''--adaptive-sync ${adaptiveSyncSetting main} ''
        + ''--output ${side.name} --preferred ''
        + ''--pos ${toString side.position.x},${toString side.position.y} ''
        + ''
          --adaptive-sync ${adaptiveSyncSetting side}
          set-xwayland-primary ${main.name}
        '';

      home.configFile."labwc/rc.xml".source =
        lib.custom.convertAttrsetToXml
        labwcRc "labwc-rc.xml" "labwc_config";
    };
}
