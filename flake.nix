{
  description = "A flexible configuration for desktop and thinkpad.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    github-nvim-theme = {
      url = "github:projekt0n/github-nvim-theme/v0.0.7";
      flake = false;
    };
    awesome = {
      url = "github:awesomeWM/awesome";
      flake = false;
    };
    awesome-code-doc = {
      url = "github:kosorin/awesome-code-doc";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";

    # own functions
    lib = nixpkgs.lib.extend (
      final: prev: {
        custom = import ./lib.nix nixpkgs.lib;
      }
    );

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [self.overlays.default];
    };
  in {
    packages."${system}" =
      lib.custom.mapModules ./packages (p: pkgs.callPackage p {});

    # package overlays
    overlays.default = import ./overlay.nix {inherit inputs system;};

    nixosModules =
      {nixosConfig = import ./.;}
      // lib.custom.mapModulesRec ./modules import;

    nixosConfigurations = let
      mkHost = system: path:
        lib.nixosSystem {
          inherit system;
          specialArgs = {inherit lib inputs system;};
          modules = [
            {
              nixpkgs.pkgs = pkgs;
              modules.device.name = lib.mkDefault (builtins.baseNameOf path);
            }
            ./. # default.nix
            (import path)
          ];
        };
    in
      lib.custom.mapModules ./hosts (mkHost system);

    devShells."${system}".default = pkgs.mkShell {
      name = "nixos-config";
      buildInputs = [
        pkgs.git
        pkgs.alejandra
        pkgs.nix-zsh-completions
        pkgs.rnix-lsp
        pkgs.luajit
      ];
    };
  };
}
