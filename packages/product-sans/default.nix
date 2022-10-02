# Google product sans font
{
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  pname = "product-sans";
  version = "1.0";

  src = ./ttf;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    install -Dm644 *.ttf $out/share/fonts/truetype
  '';

  meta = {
    description = "Product Sans is a proprietary font made by Google.";
    homepage = "https://befonts.com/product-sans-font.html";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
