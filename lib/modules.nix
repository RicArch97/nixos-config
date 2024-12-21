# functions to map a function over modules to import all modules at once
{
  inputs,
  lib,
  pkgs,
  ...
}: rec {
  mapModules = dir: func:
    lib.filterAttrs (_: v: v != null) (lib.mapAttrs'
      (n: v: let
        path = "${toString dir}/${n}";
      in
        if v == "directory" && builtins.pathExists "${path}/default.nix"
        then lib.nameValuePair n (func path)
        else if v == "regular" && n != "default.nix" && lib.hasSuffix ".nix" n
        then lib.nameValuePair (lib.removeSuffix ".nix" n) (func path)
        else lib.nameValuePair "" null)
      (builtins.readDir dir));

  mapModules' = dir: func: builtins.attrValues (mapModules dir func);

  mapModulesRec = dir: func:
    lib.filterAttrs (_: v: v != null) (lib.mapAttrs'
      (n: v: let
        path = "${toString dir}/${n}";
      in
        if v == "directory"
        then lib.nameValuePair n (mapModulesRec path func)
        else if v == "regular" && n != "default.nix" && lib.hasSuffix ".nix" n
        then lib.nameValuePair (lib.removeSuffix ".nix" n) (func path)
        else lib.nameValuePair "" null)
      (builtins.readDir dir));

  mapModulesRec' = dir: func: let
    dirs =
      lib.mapAttrsToList (k: _: "${dir}/${k}")
      (lib.filterAttrs (_: v: v == "directory") (builtins.readDir dir));
    files = builtins.attrValues (mapModules dir lib.id);
    paths = files ++ builtins.concatLists (builtins.map (d: mapModulesRec' d lib.id) dirs);
  in
    builtins.map func paths;
}
