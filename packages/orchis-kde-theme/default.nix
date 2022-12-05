{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "Orchis-kde";
  version = "5838ba2abaea02211198dcd3fbd011b2f175f97f";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    rev = version;
    hash = "sha256-4bgBzUjBp7IEdaK01AnE8Qx9+3jqEl44W96n/T4Hn9M=";
  };

  installPhase = ''
    runHook preInstall
    patchShebangs install.sh
    substituteInPlace install.sh \
      --replace '$HOME/.local' $out \
      --replace '$HOME/.config' $out/share
    name= ./install.sh --dest $out/share/themes
    mkdir -p $out/share/sddm/themes
    cp -a sddm/Orchis $out/share/sddm/themes/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Orchis kde is a materia Design theme for KDE Plasma desktop.";
    homepage = "https://github.com/vinceliuice/Orchis-kde";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
