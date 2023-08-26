# Asynchronous API wrapper for LGI
{
  lib,
  luajit,
  luajitPackages,
  fetchFromGitHub,
  custom,
}:
luajit.pkgs.buildLuarocksPackage rec {
  pname = "lgi-async-extra";
  version = "scm-1";

  src = fetchFromGitHub {
    owner = "sclu1034";
    repo = pname;
    rev = "45281ceaf42140f131861ca6d1717912f94f0bfd";
    hash = "sha256-4Lydw1l3ETLzmsdQu53116rn2oV+XKDDpgxpa3yFbYM=";
  };

  preConfigure = ''
    ln -s rocks/${pname}-${version}.rockspec .
  '';

  propagatedBuildInputs = [custom.async-lua luajit luajitPackages.lgi];

  meta = {
    description = "An asynchronous high(er)-level API wrapper for LGI.";
    homepage = "https://github.com/sclu1034/lgi-async-extra";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
