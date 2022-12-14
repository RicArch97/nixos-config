{
  description = "A flexible configuration for desktop and thinkpad.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dunst-fork = {
      url = "github:k-vernooy/dunst/progress-styling";
      flake = false;
    };
    github-nvim-theme = {
      url = "github:projekt0n/github-nvim-theme";
      flake = false;
    };
    swayfx = {
      url = "github:WillPower3309/swayfx";
      inputs.nixpkgs.follows = "nixpkgs";
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
      name = "nixos-config shell";
      packages = [
        pkgs.git
        pkgs.alejandra
        pkgs.nix-zsh-completions
        pkgs.rnix-lsp
      ];
    };
  };
}
