# Configuration for the gtklock screen locker
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  lockConfig = config.modules.desktop.util.gtklock;
  apps = config.modules.desktop.default-apps;
  gtkConfig = config.modules.desktop.themes.gtk;
  device = config.modules.device;
  colorScheme = config.modules.desktop.themes.colors;
in {
  options.modules.desktop.util.gtklock = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = let
    gtklock-blur = let
      outputs =
        if (device.name == "X570AM")
        then "(DP-1 DP-2)"
        else "(eDP-1)";
      gtklock-style =
        pkgs.writeText "gtklock-style.css" ''
          #clock-label {
            margin-bottom: 50px;
            font-size: 800%;
            font-weight: bold;
            color: ${colorScheme.types.foreground};
          }
          #body {
            margin-top: 50px;
          }
          #input-label {
            color: ${colorScheme.types.foreground};
          }
          window {
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            background-color: ${colorScheme.types.background};
          }
        ''
        // lib.optionalString (device.name == "X570AM") ''
          window#DP-1 {
            background-image: url("/tmp/DP-1.png");
          }
          window#DP-2 {
            background-image: url("/tmp/DP-2.png");
          }
        ''
        // lib.optionalString (device.name == "T470") ''
          window#eDP-1 {
            background-image: url("/tmp/eDP-1.png");
          }
        '';
    in
      # run these heavy processes async where possible
      pkgs.writeShellScript "gtklock-blur" ''
        outdir="/tmp/gtklock"
        outputs=${outputs}

        mkdir -p $outdir

        convertImg() {
          ${pkgs.grim}/bin/grim -o $o "$outdir/$o.png"
          size=$(identify -format "%wx%h" "$outdir/$o.png")
          pids=""
          convert "$outdir/$o.png" -filter Gaussian -resize 50% \
            -define filter:sigma=3 -resize 200% "$outdir/$o.png" &
          pids="$pids $!"
          magick -size "$size" radial-gradient:black-white \
            -contrast-stretch 3%x0% "$outdir/$o-gradient.png" &
          pids="$pids $!"
          wait $pids
          convert "$outdir/$o.png" "$outdir/$o-gradient.png" \
            -compose multiply -composite "$outdir/$o.png"
        }

        for o in ''${outputs[@]}; do
          convertImg &
        done

        wait

        ${pkgs.gtklock}/bin/gtklock -d -s ${gtklock-style}
      '';
  in
    lib.mkIf (lockConfig.enable) {
      apps.defaultApps.locker = rec {
        package = pkgs.gtklock;
        cmd = gtklock-blur;
        desktop = "gtklock";
      };

      # for fingerprint reader unlocks
      services.fprintd.enable = lib.mkIf (device.hasFingerprint) true;

      # allow gtklock to unlock the screen
      security.pam.services.gtklock.text =
        if (device.hasFingerprint)
        then ''
          auth sufficient pam_unix.so try_first_pass likeauth nullok
          auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
          auth include login
        ''
        else ''
          auth include login
        '';

      # used to screenshot and apply blur / gradient to an image
      user.packages = [pkgs.grim pkgs.imagemagick];
    };
}
