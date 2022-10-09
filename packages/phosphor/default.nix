# Phosphor icon font
{
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  pname = "phosphor";
  version = "1.4.0";

  src = ./ttf;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    install -Dm644 *.ttf $out/share/fonts/truetype
  '';

  meta = {
    description = "Phosphor is a flexible icon family for interfaces, diagrams, presentations — whatever, really.";
    homepage = "https://phosphoricons.com/";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
