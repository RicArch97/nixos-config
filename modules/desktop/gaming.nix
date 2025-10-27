# Configuration for gaming (Steam, Lutris)
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  gameConfig = config.modules.desktop.gaming;
  device = config.modules.device;
in {
  options.modules.desktop.gaming = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (gameConfig.enable) {
    # Steam hardware (just in case)
    hardware.steam-hardware.enable = true;

    # Steam, Gamemode
    programs = {
      steam.enable = true;
      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 10;
          };
          custom = {
            start = "${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations activated'";
            end = "${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations deactivated'";
          };
        };
      };
    };

    # required since gamemode 1.8 to change CPU governor
    user.extraGroups = ["gamemode"];

    # lutris for non-steam games, wine, vulkan tools for driver checks
    home.packages = [
      (pkgs.lutris.override {
        extraPkgs = pkgs: [
          pkgs.jansson
        ];
      })
      pkgs.wineWowPackages.stable
      pkgs.vulkan-tools
    ];

    # improvement for games using lots of mmaps
    boot.kernel.sysctl."vm.max_map_count" = 1048576;
  };
}
