{
  inputs,
  system,
  ...
}: final: prev: let
  github-nvim-theme = prev.vimUtils.buildVimPlugin {
    name = "github-nvim-theme";
    src = inputs.github-nvim-theme;
    dontBuild = true;
  };
in {
  # stable packages
  stable = import inputs.nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  # own packages
  custom = inputs.self.packages."${system}";

  # Extra Vim / Neovim plugins
  vimPlugins =
    prev.vimPlugins
    // {
      inherit github-nvim-theme;
    };

  # SwayFX
  sway-unwrapped = inputs.swayfx.packages.${system}.default;

  # XWayland uncapped FPS patch
  xwayland = prev.xwayland.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./patches/xwayland-vsync.patch
      ];
  });
}
