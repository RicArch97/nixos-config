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
  yuck-vim = prev.vimUtils.buildVimPlugin {
    name = "yuck.vim";
    src = inputs.yuck-vim;
  };
in {
  # own packages
  custom = inputs.self.packages."${system}";

  # Extra Vim / Neovim plugins
  vimPlugins =
    prev.vimPlugins
    // {
      inherit github-nvim-theme;
      inherit yuck-vim;
    };

  # Dunst fork from k-vernooy that makes the progress bar look nicer
  dunst = prev.dunst.overrideAttrs (old: {
    src = inputs.dunst-fork;
  });

  # Needed dependency for Overwatch 2
  lutris = prev.lutris.override {extraPkgs = pkgs: [pkgs.jansson];};
}
