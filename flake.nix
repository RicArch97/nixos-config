{
  description = "A flexible configuration for desktop and thinkpad.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    github-nvim-theme = {
      url = "github:projekt0n/github-nvim-theme/v0.0.7";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";

    lib = import ./lib {
      inherit pkgs inputs;
      lib = nixpkgs.lib;
    };

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
        pkgs.nil
      ];
    };
  };
}
