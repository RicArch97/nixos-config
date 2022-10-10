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
  # own packages
  custom = inputs.self.packages."${system}";

  # Extra Vim / Neovim plugins
  vimPlugins =
    prev.vimPlugins
    // {
      inherit github-nvim-theme;
    };

  # Dunst fork from k-vernooy that makes the progress bar look nicer
  dunst = prev.dunst.overrideAttrs (old: {
    src = inputs.dunst-fork;
  });

  # discord OpenAsar and NSS fix
  discord = prev.discord.override {
    withOpenASAR = true;
    nss = prev.nss_latest;
  };
}
