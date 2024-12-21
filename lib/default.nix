# custom nix functions (not in default nix lib)
{
  inputs,
  lib,
  pkgs,
  ...
}:
lib.extend (
  final: prev: let
    importLib = file: import file {inherit inputs lib pkgs;};
    merge = lib.foldr (a: b: a // b) {};
    importLibs = libs: merge (builtins.map importLib libs);

    isLib = name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name;
    libPath = name: "${toString ./.}/${name}";
    libsInFolder = map libPath (builtins.attrNames (lib.filterAttrs isLib (builtins.readDir ./.)));
  in {
    custom = importLibs libsInFolder;
  }
)
