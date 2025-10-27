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
  # master branch packages (for packages that break too often)
  master = import inputs.nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
    config.permittedInsecurePackages = [
      "segger-jlink-qt4-874"
    ];
    config.segger-jlink.acceptLicense = true;
  };
  # own packages
  custom = inputs.self.packages."${system}";

  # Extra Vim / Neovim plugins
  vimPlugins =
    prev.vimPlugins
    // {
      inherit github-nvim-theme;
    };
}
