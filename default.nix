{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports =
    [inputs.home-manager.nixosModules.home-manager]
    ++ (lib.custom.mapModulesRec' ./modules import);

  environment.variables.NIXOSCONFIG = config.nixosConfig.dir;
  environment.variables.NIXOSCONFIG_BIN = config.nixosConfig.binDir;
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  nix = let
    regInputs =
      lib.mapAttrs (_: v: {flake = v;})
      (lib.filterAttrs (n: _: n != "self") inputs);
  in {
    package = pkgs.nixFlakes;
    optimise.automatic = true;
    nixPath = ["nixosConfig=${config.nixosConfig.dir}"];
    registry = regInputs // {nixosConfig.flake = inputs.self;};
    settings = {trusted-users = ["root" "${config.user.name}" "@wheel"];};
    extraOptions = "experimental-features = nix-command flakes";
  };

  system.stateVersion = lib.mkDefault "22.11";
}
