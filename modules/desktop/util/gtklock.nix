# Configuration for the gtklock screen locker
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  lockConfig = config.modules.desktop.util.gtklock;
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
    outputs =
      if device.name == "X570AM"
      then "(DP-1 DP-2)"
      else "(eDP-1)";
    gtklock-style = pkgs.writeText "gtklock-style.css" (
      ''
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
      + lib.optionalString (device.name == "X570AM") ''
        window#DP-1 {
          background-image: url("/tmp/gtklock/DP-1.png");
        }
        window#DP-2 {
          background-image: url("/tmp/gtklock/DP-2.png");
        }
      ''
      + lib.optionalString (device.name == "T470") ''
        window#eDP-1 {
          background-image: url("/tmp/gtklock/eDP-1.png");
        }
      ''
    );
    gtklock-blur = pkgs.writeShellScriptBin "gtklock-blur" ''
      outdir="/tmp/gtklock"
      outputs=${outputs}

      mkdir -p $outdir

      convertImg() {
        ${pkgs.grim}/bin/grim -o $o "$outdir/$o.png"
        size=$(identify -format "%wx%h" "$outdir/$o.png")

        convert "$outdir/$o.png" -filter Gaussian -resize 50% \
          -define filter:sigma=3 -resize 200% "$outdir/$o.png"

        magick -size "$size" radial-gradient:black-white \
          -contrast-stretch 3%x0% "$outdir/$o-gradient.png"

        convert "$outdir/$o.png" "$outdir/$o-gradient.png" \
          -compose multiply -composite "$outdir/$o.png"

        rm "$outdir/$o-gradient.png"
      }

      for o in ''${outputs[@]}; do
        convertImg &
      done

      wait

      exec ${pkgs.custom.gtklock}/bin/gtklock -s ${gtklock-style}
    '';
  in
    lib.mkIf (lockConfig.enable) {
      # add script as binary to execute by other programs such as eww
      home.packages = [
        pkgs.custom.gtklock
        pkgs.at-spi2-core
        pkgs.grim
        pkgs.imagemagick
        gtklock-blur
      ];

      modules.desktop.defaultApplications.apps.locker = {
        package = pkgs.custom.gtklock;
        cmd = "gtklock-blur";
        desktop = "gtklock";
      };

      # for fingerprint reader unlocks
      services.fprintd.enable = lib.mkIf (device.hasFingerprint) true;

      # allow gtklock to unlock the screen
      security.pam.services.gtklock.text =
        if device.hasFingerprint
        then ''
          auth sufficient pam_unix.so try_first_pass likeauth nullok
          auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
          auth include login
        ''
        else ''
          auth include login
        '';
    };
}
