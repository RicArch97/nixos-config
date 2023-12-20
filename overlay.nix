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

  # Battle.net dependency
  lutris = prev.lutris.override {extraPkgs = pkgs: [pkgs.jansson];};

  # XWayland uncapped FPS patch
  xwayland = prev.xwayland.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./patches/xwayland-vsync.patch
      ];
  });

  # git LuaJIT version of Awesome
  awesome-luajit-git = let
    extraGIPackages = [prev.playerctl];
  in
    (prev.awesome.override {
      lua = prev.luajit;
      gtk3Support = true;
    })
    .overrideAttrs (old: {
      src = inputs.awesome;
      version = "${old.version}-git";

      patches = [];

      postPatch = ''
        patchShebangs tests/examples/_postprocess.lua
        patchShebangs tests/examples/_postprocess_cleanup.lua
      '';

      cmakeFlags = old.cmakeFlags ++ ["-DGENERATE_MANPAGES=OFF"];

      GI_TYPELIB_PATH = let
        mkTypeLibPath = pkg: "${pkg}/lib/girepository-1.0";
        extraGITypeLibPaths = prev.lib.forEach extraGIPackages mkTypeLibPath;
      in
        prev.lib.concatStringsSep ":" (extraGITypeLibPaths ++ [(mkTypeLibPath prev.pango.out)]);
    });
}
