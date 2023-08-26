# Lua Dbus Proxy package to easily listen for DBus events
{
  lib,
  luajit,
  luajitPackages,
  fetchFromGitHub,
}:
luajit.pkgs.buildLuaPackage rec {
  pname = "dbus_proxy";
  version = "0.10.3";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "stefano-m";
    repo = "lua-${pname}";
    rev = "v${version}";
    sha256 = "sha256-Yd8TN/vKiqX7NOZyy8OwOnreWS5gdyVMTAjFqoAuces=";
  };

  propagatedBuildInputs = [luajitPackages.lgi];
  buildPhase = ":";

  installPhase = ''
    mkdir -p "$out/share/lua/${luajit.luaversion}"
    cp -r src/${pname} "$out/share/lua/${luajit.luaversion}/"
  '';

  meta = {
    description = "DBus Proxy Object for Lua";
    homepage = "https://github.com/stefano-m/lua-dbus_proxy/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
