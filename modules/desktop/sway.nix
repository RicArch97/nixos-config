# Configuration for the Sway wayland compositor
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  swayConfig = config.modules.desktop.sway;
  device = config.modules.device;
  defaultApps = config.modules.desktop.defaultApplications.apps;
  colorScheme = config.modules.desktop.themes.colors;
  fontConfig = config.modules.desktop.themes.fonts.styles;
  gtkConfig = config.modules.desktop.themes.gtk;
in {
  options.modules.desktop.sway = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    # In case I don't require it anymore at some point
    xwayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (swayConfig.enable) {
    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      extraPackages = lib.mkMerge [
        (lib.mkIf (swayConfig.xwayland) [
          pkgs.xwayland
          pkgs.xorg.xrandr
        ])
      ];
      # Sway / Wayland specific environment variables
      extraSessionCommands = ''
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=sway
        export XDG_CURRENT_DESKTOP=sway
        export QT_QPA_PLATFORM=wayland
        export CLUTTER_BACKEND=wayland
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      # Launches Sway with required envvars for GTK apps
      wrapperFeatures.gtk = true;
    };

    # utilized packages in the config / util
    home.packages = [
      pkgs.swaybg
      pkgs.swaysome
      pkgs.playerctl
      pkgs.pamixer
      pkgs.slurp
      pkgs.dex
      pkgs.wlclock
      pkgs.wl-clipboard
      pkgs.wlr-randr
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

    # brightness support
    programs.light.enable = lib.mkIf (device.supportsBrightness) true;

    # use gsettings
    modules.desktop.themes.gtk.gsettings.enable = true;

    # some default apps used with Wayland / Sway
    modules.desktop.defaultApplications.apps = {
      screenshot = rec {
        package = pkgs.sway-contrib.grimshot;
        cmd = "${package}/bin/grimshot";
        desktop = "grimshot";
      };
      image-viewer = rec {
        package = pkgs.imv;
        cmd = "${package}/bin/imv";
        desktop = "imv";
      };
    };

    # enable firefox wayland, eww wayland & rofi
    modules.desktop.apps.browsers.firefox.enable = true;
    modules.desktop.services.eww.enable = true;
    modules.desktop.util.rofi = {
      enable = true;
      menu.enable = true;
    };

    # for volume and brightness level notification
    modules.desktop.services.dunst.enable = true;

    # enable swayidle and gtklock modules
    modules.desktop.services.swayidle.enable = true;
    modules.desktop.util.gtklock.enable = true;

    # enable greetd as display manager for Sway
    modules.services.greetd.enable = true;

    # polkit auth agent for GUI authentication
    modules.desktop.services.polkit.enable = true;

    # make sure Electron apps use the Wayland backend by setting this flag
    env.NIXOS_OZONE_WL = "1";

    # allows sway to request real-time priority
    security.pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];

    # Home manager configuration
    home.manager.wayland.windowManager.sway = {
      enable = true;
      package = null; # don't override system-installed one
      checkConfig = false; # doesn't work with new SwayFX options
      config = {
        # Modifier (super key)
        modifier = "Mod4";
        # Default movement keys (arrow keys, TKL keyboard)
        left = "Left";
        down = "Down";
        up = "Up";
        right = "Right";
        # Programs
        menu = "${defaultApps.menu.cmd}";
        terminal = "${defaultApps.terminal.cmd}";
        # No sway bar
        bars = [];

        # Theming
        colors = let
          ct = colorScheme.types;
          cc = colorScheme.colors;
        in {
          background = ct.background;
          focused = {
            background = ct.background-darker;
            border = ct.border;
            childBorder = ct.border;
            indicator = ct.border;
            text = cc.color15;
          };
          focusedInactive = {
            background = ct.background-darker;
            border = ct.border;
            childBorder = ct.border;
            indicator = ct.border;
            text = ct.foreground;
          };
          unfocused = {
            background = ct.background-darker;
            border = ct.border;
            childBorder = ct.border;
            indicator = ct.border;
            text = ct.foreground;
          };
        };
        fonts = {
          names = [fontConfig.sub.family];
          style = "Bold";
          size = 10.5;
        };

        # Window properties
        gaps = {
          outer = 5;
          inner = 10;
        };
        floating = {
          border = 1;
          titlebar = true;
          criteria = [
            {window_role = "pop-up";}
            {window_role = "bubble";}
            {window_role = "dialog";}
            {window_type = "dialog";}
            {app_id = "alacritty";} # keybind for floating
            {app_id = "engrampa";}
            {app_id = "openrgb";}
            {app_id = "lutris";}
            {app_id = "pavucontrol";}
            {class = ".*.exe";} # Wine apps
            {class = "steam_app.*";} # Steam games
            {class = "steam";} # Steam itself
          ];
        };

        # Disable mouse acceleration on desktop for all inputs
        input = {
          "*" = {
            accel_profile = "flat";
            pointer_accel = "0";
            middle_emulation = "disabled";
          };
        };

        # Keybinds
        keybindings = let
          mod = config.home.manager.wayland.windowManager.sway.config.modifier;
          inherit
            (config.home.manager.wayland.windowManager.sway.config)
            left
            down
            up
            right
            ;
          # Generate a list of lists, each inner list containing a key(number) and workspace
          workspaces = lib.genList (x: [(toString (x + 1)) (toString (x + 1))]) 8;
        in
          {
            # General
            "${mod}+Shift+q" = "kill";
            "${mod}+Return" = "exec ${defaultApps.terminal.cmd}";
            "${mod}+Shift+Return" = "exec ${defaultApps.terminal.cmd} --class='alacritty'";
            "${mod}+d" = "exec ${defaultApps.menu.cmd}";
            "${mod}+Shift+c" = "reload";
            "${mod}+l" = "exec ${defaultApps.locker.cmd}";
            "${mod}+Print" = "exec ${defaultApps.screenshot.cmd} --notify save output";
            "${mod}+Shift+Print" = "exec ${defaultApps.screenshot.cmd} --notify save area";
            "${mod}+Shift+p" = "exec ${defaultApps.screenshot.cmd} --notify save screen";

            # Moving focus
            "${mod}+${left}" = "focus left";
            "${mod}+${down}" = "focus down";
            "${mod}+${up}" = "focus up";
            "${mod}+${right}" = "focus right";
            "${mod}+Shift+${left}" = "move left";
            "${mod}+Shift+${down}" = "move down";
            "${mod}+Shift+${up}" = "move up";
            "${mod}+Shift+${right}" = "move right";

            # Workspaces
            #
            # Move focused container to next output
            "${mod}+o" = "exec ${pkgs.swaysome}/bin/swaysome next-output";
            # Move focused container to previous output
            "${mod}+Shift+o" = "exec ${pkgs.swaysome}/bin/swaysome prev-output";

            # Layout stuff
            #
            # Split for horizontal and vertical
            "${mod}+h" = "splith";
            "${mod}+v" = "splitv";

            # Style, fullscreen & focus
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+f" = "fullscreen";
            "${mod}+Shift+space" = "floating toggle";
            "${mod}+space" = "focus mode_toggle";
            "${mod}+a" = "focus parent";

            # Modes
            #
            # Resize
            "${mod}+r" = "mode resize";

            # Scratchpad
            #
            # Move window to scratchpad
            "${mod}+Shift+minus" = "move scratchpad";
            # Show scratchpad or cycle to next window
            "${mod}+minus" = "scratchpad show";

            # Special keys
            #
            # Audio
            "XF86AudioRaiseVolume" = "exec set-volume inc 1";
            "XF86AudioLowerVolume" = "exec set-volume dec 1";
            "XF86AudioMute" = "exec set-volume toggle-mute";
            "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";
            "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
            "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          }
          # Set brightness keys for ThinkPad laptop
          // lib.optionalAttrs (device.supportsBrightness) {
            "XF86MonBrightnessDown" = "exec set-brightness dec 1";
            "XF86MonBrightnessUp" = "exec set-brightness inc 1";
          }
          # Merge number key to focus workspace number with keybind set
          // lib.listToAttrs (builtins.map
            (x: {
              name = "${mod}+${builtins.elemAt x 0}";
              value = "exec ${pkgs.swaysome}/bin/swaysome focus ${builtins.elemAt x 1}";
            })
            workspaces)
          # Merge number key to move to workspace number with keybind set
          // lib.listToAttrs (builtins.map
            (x: {
              name = "${mod}+Shift+${builtins.elemAt x 0}";
              value = "exec ${pkgs.swaysome}/bin/swaysome move ${builtins.elemAt x 1}";
            })
            workspaces);

        # Modes
        modes = {
          resize = let
            inherit
              (config.home.manager.wayland.windowManager.sway.config)
              left
              down
              up
              right
              ;
          in {
            # Resize in big chunks, mouse for precision
            "${left}" = "resize shrink width 50px";
            "${right}" = "resize grow width 50px";
            "${down}" = "resize shrink height 50px";
            "${up}" = "resize grow height 50px";
            Return = "mode default";
            Escape = "mode default";
          };
        };

        output =
          lib.foldl'
          (item: acc: acc // item) {} (
            lib.mapAttrsToList (_: monitor: {
              "${monitor.name}" = {
                pos = "${toString monitor.position.x} ${toString monitor.position.y}";
                mode = "${monitor.resolution}@${toString monitor.refresh_rate}Hz";
                max_render_time = "2";
                adaptive_sync =
                  if monitor.adaptive_sync
                  then "on"
                  else "off";
              };
            })
            device.monitors
          );

        # Seat configuration
        seat = {
          seat0.xcursor_theme = "${gtkConfig.cursorTheme.name} ${toString gtkConfig.cursorTheme.size}";
        };

        # Autostart applications / stuff
        startup =
          [
            {command = "${pkgs.swaysome}/bin/swaysome init 1";}
            {command = "${pkgs.dex}/bin/dex -a -s ~/.config/autostart/";}
            {command = "configure-gtk";}
            {command = "set-wallpaper-wayland restore";}
            # Make sure systemd user services have access to these, currently used by eww
            {command = "systemctl --user import-environment I3SOCK GDK_PIXBUF_MODULE_FILE";}
          ]
          ++ lib.optionals (device.name == "North" || device.name == "X570AM") [
            {command = "launch-wlclock 'DP-1' '${colorScheme.types.background-darker}' '${colorScheme.types.foreground}'";}
            {command = "eww open-many bar-left-main bar-right-main bar-left-side";}
            {command = "set-xwayland-primary ${device.monitors.main.name}";}
          ];

        # Window settings / rules
        window = {
          border = 1;
          commands = let
            floatSize =
              if device.bigScreen
              then "1700 1000"
              else "1200 700";
          in [
            {
              command = "inhibit_idle fullscreen";
              criteria = {app_id = "firefox";};
            }
            {
              command = "inhibit_idle fullscreen";
              criteria = {app_id = "Google-chrome";};
            }
            {
              command = "resize set ${floatSize}";
              criteria = {app_id = "alacritty";};
            }
            {
              command = "resize set ${floatSize}";
              criteria = {app_id = "openrgb";};
            }
            {
              command = "border csd";
              criteria = {app_id = "lutris";};
            }
            {
              command = "border none";
              criteria = {class = ".*.exe";};
            } # Wine apps
            {
              command = "border none";
              criteria = {class = "steam_app.*";};
            } # Steam games
          ];
          titlebar = true;
        };
      };
      # SwayFX options / other
      extraConfig =
        ''
          title_align center
          titlebar_border_thickness 1
          titlebar_padding 7
          titlebar_separator disable
          corner_radius 12
          shadows enable
          shadow_blur_radius 15
          shadow_color #000000FF
          blur enable
          blur_passes 3
        ''
        + lib.optionalString (swayConfig.xwayland) ''
          xwayland force
        '';
      # XWayland support for legacy X11 apps (enabled from module options)
      xwayland = swayConfig.xwayland;
    };
  };
}
