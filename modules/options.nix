# Defines the user and home manager options (credit to hlissner, KubqoA)
{
  config,
  options,
  lib,
  home-manager,
  ...
}: {
  options = {
    user = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
    nixosConfig = {
      dir = lib.mkOption {
        type = lib.types.path;
        default = lib.removePrefix "/mnt" (
          lib.findFirst lib.pathExists (toString ../.) [
            "/mnt/etc/nixos-config"
            "/mnt/nixos-config"
          ]
        );
      };
      binDir = lib.mkOption {
        type = lib.types.path;
        default = "${config.nixosConfig.dir}/bin";
      };
      configDir = lib.mkOption {
        type = lib.types.path;
        default = "${config.nixosConfig.dir}/config";
      };
      modulesDir = lib.mkOption {
        type = lib.types.path;
        default = "${config.nixosConfig.dir}/modules";
      };
    };
    home = {
      file = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };
      configFile = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };
      manager = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      };
    };
    env = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.path
          (
            lib.types.listOf (lib.types.either lib.types.str lib.types.path)
          )
        ]
      );
      apply = lib.mapAttrs (n: v:
        if lib.isList v
        then lib.concatMapStringsSep ":" (x: toString x) v
        else (toString v));
      default = {};
    };
  };

  config = {
    user = let
      defaultUser = "ricardo";
      user = builtins.getEnv "USER";
      name =
        if lib.elem user ["" "root"]
        then defaultUser
        else user;
    in {
      inherit name;
      description = "Primary user account";
      home = "/home/${name}";
      isNormalUser = true;
      group = "users";
      extraGroups = ["wheel"];
      uid = 1000;
    };

    # home manager configuration
    home-manager = {
      useUserPackages = true;
      users.${config.user.name} = lib.mkAliasDefinitions options.home.manager;
    };

    # home.manager is an alias for having to write home-manager.users.<user>
    home.manager = {
      # link to home file
      home = {
        stateVersion = config.system.stateVersion;
        file = lib.mkAliasDefinitions options.home.file;
        packages = lib.mkAliasDefinitions options.home.packages;
      };
      xdg = {
        enable = true;
        configFile = lib.mkAliasDefinitions options.home.configFile;
        # creates and manages folders like Downloads, Documents by default in $HOME
        userDirs = {
          enable = true;
          createDirectories = true;
          extraConfig = {XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";};
        };
      };
    };

    # link to user config
    users.users.${config.user.name} = lib.mkAliasDefinitions options.user;

    # nix configuration set new user and root as trusted to connect to the nix daemon
    nix.settings = let
      users = ["root" config.user.name];
    in {
      trusted-users = users;
      allowed-users = users;
    };

    # set default XDG dirs
    environment = {
      sessionVariables = {
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_BIN_HOME = "$HOME/.local/bin/";
      };
      extraInit =
        lib.concatStringSep "\n"
        (lib.mapAttrsToList (n: v: ''export ${n}="${v}"'') config.env);
    };

    # add user binary path to PATH
    env.PATH = ["NIXOSCONFIG_BIN" "$XDG_BIN_HOME" "$PATH"];
  };
}
