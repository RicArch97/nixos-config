# Configuration for Neovim
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  nvimConfig = config.modules.desktop.apps.neovim;
  configDir = config.nixosConfig.configDir;
in {
  options.modules.desktop.apps.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (nvimConfig.enable) {
    modules.desktop.defaultApplications.apps.editor = rec {
      package = pkgs.neovim;
      install = false; # installed by home manager
      cmd = "${package}/bin/nvim";
      desktop = "nvim";
    };

    # language servers
    home.packages = [
      pkgs.rnix-lsp
      pkgs.ccls
      pkgs.nodePackages.pyright
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.bash-language-server
      pkgs.sumneko-lua-language-server
      pkgs.haskell-language-server
      pkgs.rust-analyzer
      pkgs.texlab
    ];

    # home manager configuration
    home.manager.programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      # source files for vim settings, plugin configs
      extraConfig = ''
        luafile ${configDir}/nvim/lua/settings.lua
        luafile ${configDir}/nvim/lua/alpha.lua
        luafile ${configDir}/nvim/lua/bufferline.lua
        luafile ${configDir}/nvim/lua/telescope.lua
        luafile ${configDir}/nvim/lua/lsp.lua
        luafile ${configDir}/nvim/lua/others.lua
      '';
      plugins = let
        vp = pkgs.vimPlugins;
      in [
        # File tree
        vp.nvim-web-devicons
        vp.nvim-tree-lua
        # LSP
        vp.nvim-lspconfig
        vp.nvim-cmp
        vp.cmp-cmdline
        vp.cmp-nvim-lsp
        vp.cmp-buffer
        vp.cmp-path
        vp.cmp-vsnip
        # Syntax
        vp.vim-nix
        vp.vim-markdown
        vp.vim-vsnip
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (
          _: pkgs.tree-sitter.allGrammars
        ))
        vp.neoformat
        vp.gitsigns-nvim
        # Addons
        vp.telescope-nvim
        vp.indent-blankline-nvim
        vp.nvim-autopairs
        vp.vim-highlightedyank
        vp.nvim-comment
        vp.editorconfig-vim
        # Looks
        vp.bufferline-nvim
        vp.lualine-nvim
        vp.github-nvim-theme # added with overlay
        vp.alpha-nvim
      ];
    };
  };
}
