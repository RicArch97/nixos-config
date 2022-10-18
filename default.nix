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
    nixPathInputs =
      lib.mapAttrsToList (n: v: "${n}=${v}")
      (lib.filterAttrs (n: _: n != "self") inputs);
    regInputs =
      lib.mapAttrs (_: v: {flake = v;})
      (lib.filterAttrs (n: _: n != "self") inputs);
  in {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    nixPath = nixPathInputs ++ ["nixos-config=${config.nixosConfig.dir}"];
    registry = regInputs // {nixosConfig.flake = inputs.self;};
    settings = {trusted-users = ["root" "${config.user.name}" "@wheel"];};
    extraOptions = "experimental-features = nix-command flakes";
  };

  # default options that apply to all hosts, unless changed

  # default timezone
  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  # default bootoptions / kernel / modules
  boot = {
    kernelParams = ["quiet"];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = lib.mkDefault true;
      systemd-boot.configurationLimit = lib.mkDefault 5;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      verbose = false;
      availableKernelModules = [
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "dm_mod"
      ];
    };
  };

  system.stateVersion = "22.11";
}
