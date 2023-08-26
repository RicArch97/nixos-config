# Utilities for async Lua
{
  lib,
  luajit,
  luajitPackages,
  fetchFromGitHub,
}:
luajit.pkgs.buildLuarocksPackage rec {
  pname = "async.lua";
  version = "scm-1";

  src = fetchFromGitHub {
    owner = "sclu1034";
    repo = pname;
    rev = "f8d8f70a1ef1f7c4d5e3e65a36e0e23d65129e92";
    hash = "sha256-zWeIZkdO5uOHI2dkzseCEj8+BldH7X1ZtfIQhDFjaQY=";
  };

  preConfigure = ''
    ln -s rocks/${pname}-${version}.rockspec .
  '';

  propagatedBuildInputs = [luajit];

  meta = {
    description = "Utilities for callback-style asynchronous Lua.";
    homepage = "https://github.com/sclu1034/async.lua";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
